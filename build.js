import { context } from "esbuild";
import pkg from "esbuild-plugin-fileloc";
import { readFile, writeFile } from "fs/promises";

const { filelocPlugin } = pkg;

async function generateManifest({ client, server, dependencies }) {
  const data = JSON.parse(await readFile("package.json", "utf8"));
  const fxmanifest = {
    fx_version: "cerulean",
    game: "gta5",
    name: data.name,
    description: data.description,
    author: data.author,
    version: data.version,
    repository: data.repository?.url,
    license: data.license,
  };

  let output = "";

  for (const [key, value] of Object.entries(fxmanifest)) {
    if (value) {
      output += `${key} "${value}"\n`;
    }
  }

  if (client?.length > 0) {
    output += `\nclient_scripts {${client.map(file => `\n\t"${file}",`).join("")}\n}\n`;
  }

  if (server?.length > 0) {
    output += `\nserver_scripts {${server.map(file => `\n\t"${file}",`).join("")}\n}\n`;
  }

  if (dependencies?.length > 0) {
    output += `\ndependencies {${dependencies.map(dep => `\n\t"${dep}",`).join("")}\n}\n`;
  }

  await writeFile("fxmanifest.lua", output);
}

async function build(development) {
  const ctx = await context({
    entryPoints: ["./client/index.ts", "./server/index.ts"],
    outdir: "./dist",
    platform: "node",
    target: "node22",
    bundle: true,
    minify: false,
    plugins: [filelocPlugin(), {
      name: "build",
      setup(build) {
        build.onEnd(result => {
          if (result.errors.length > 0) {
            console.log(`Build ended with ${result.errors.length} errors`);
            result.errors.forEach((error, i) => console.error(`Error ${i + 1}:`, error.text));
          } else {
            console.log(development ? "Successfully built (development)" : "Successfully built (production)");
            if (!development) {
              generateManifest({
                client: ["dist/client/*.js"],
                server: ["dist/server/*.js"],
                dependencies: ["/server:12913", "/onesync", "ox_lib", "ox_core"],
              }).then(() => {
                console.log("fxmanifest.lua generated successfully.");
                process.exit(0);
              }).catch((err) => {
                console.error("Failed to generate fxmanifest:", err);
                process.exit(1);
              });
            }
          }
        });
      },
    }],
  });

  if (development) {
    await ctx.watch().catch(() => process.exit(1));
  } else {
    await ctx.rebuild().then(() => {
      console.log("Production build completed successfully.");
    }).catch(() => {
      console.error("Failed during production build.");
      process.exit(1);
    });
  }
}

process.argv.includes("--watch") ? build(true) : build(false);