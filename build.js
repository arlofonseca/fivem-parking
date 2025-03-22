import { context } from 'esbuild';
import { access, constants, readFile, writeFile } from 'fs/promises';
import path from 'path';
import process from 'process';

async function generateManifest({ client, server, dependencies, metadata }) {
  const data = JSON.parse(await readFile('package.json', 'utf8'));
  const fxmanifest = {
    fx_version: 'cerulean',
    game: 'gta5',
    name: data.name,
    description: data.description,
    author: data.author,
    version: data.version,
    repository: data.repository?.url,
    license: data.license,
    ...(metadata || {}),
  };

  let output = [];
  for (const [key, value] of Object.entries(fxmanifest)) {
    if (value) {
      output.push(`${key} '${value}'`);
    }
  }

  const append = (type, option) => {
    if (option?.length > 0) {
      output.push(
        `\n${type}${type === 'dependencies' ? '' : '_scripts'} {${option.map((item) => `\n\t'${item}'`).join(',')}\n}`,
      );
    }
  };

  append('client', client);
  append('server', server);
  append('dependencies', dependencies);

  await writeFile('fxmanifest.lua', output.join('\n'));
}

async function build(development) {
  const ctx = await context({
    entryPoints: ['./src/client/index.ts', './src/server/index.ts'],
    outdir: './dist',
    platform: 'node',
    target: 'node22',
    bundle: true,
    minify: false,
    plugins: [
      {
        name: 'build',
        setup(build) {
          build.onLoad({ filter: /.\.(js|ts)$/ }, async (args) => {
            const data = await readFile(args.path, 'utf-8');
            const escape = (p) => (/^win/.test(process.platform) ? p.replace(/\\/g, '/') : p);

            const global = /__(?=(filename|dirname))/g;
            const cache = global.test(data);

            const location = cache
              ? `const location = { filename: '${escape(args.path)}', dirname: '${escape(path.dirname(args.path))}' }; let __line = 0;\n`
              : '';

            const insert = data
              .split('\n')
              .map((line, index) => {
                return `${line.includes('__line') ? `__line=${index + 1};` : ''}${line}`;
              })
              .join('\n');

            return {
              contents: cache ? location + insert.replace(global, 'location.') : insert,
              loader: path.extname(args.path).slice(1),
            };
          });

          build.onEnd(async (result) => {
            if (result.errors.length > 0) {
              console.error(`Build ended with ${result.errors.length} error(s):`);
              result.errors.forEach((error, i) => {
                console.error(`Error ${i + 1}: ${error.text}`);
              });
              return;
            }

            console.log(development ? 'Successfully built (development)' : 'Successfully built (production)');

            if (!development) {
              await generateManifest({
                client: ['dist/client/*.js'],
                server: ['dist/server/*.js'],
                dependencies: ['/server:12913', '/onesync', 'ox_lib', 'ox_core', 'ox_inventory'],
                metadata: { node_version: '22' },
              });
              process.exit(0);
            }
          });
        },
      },
    ],
  });

  if (development) {
    try {
      await access('fxmanifest.lua', constants.F_OK);
    } catch (error) {
      console.log('fxmanifest.lua not found, run `pnpm build` to generate it.');
      process.exit(1);
    }
    await ctx.watch();
    console.log('Watching for changes...');
  } else {
    await ctx.rebuild();
  }
}

process.argv.includes('--watch') ? build(true) : build(false);
