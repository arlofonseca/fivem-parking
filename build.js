import { build, context } from 'esbuild';
import pkg from 'esbuild-plugin-fileloc';

const { filelocPlugin } = pkg;
const watch = process.argv.includes('--watch');

async function development() {
  const ctx = await context({
    entryPoints: ['./client/index.ts', './server/index.ts'],
    outdir: './dist',
    platform: 'node',
    target: 'ES2022',
    bundle: true,
    minify: false,
    plugins: [
      filelocPlugin(),
      {
        name: 'dev',
        setup(build) {
          build.onEnd(result => {
            if (result.errors.length > 0) {
              console.log(`Build ended with ${result.errors.length} errors`);
              result.errors.forEach((error, i) => console.error(`Error ${i + 1}:`, error.text));
            } else {
              console.log('Successfully built (development)');
            }
          });
        },
      },
    ],
  });

  await ctx.watch().catch(() => process.exit(1));
}

function production() {
  build({
    entryPoints: ['./client/index.ts', './server/index.ts'],
    outdir: './dist',
    platform: 'node',
    target: 'ES2022',
    bundle: true,
    minify: false,
    plugins: [filelocPlugin()],
  })
    .then(() => {
      console.log('Successfully built (production)');
    })
    .catch(error => {
      console.error('Failed building (production):', error);
      process.exit(1);
    });
}

watch ? development() : production();