import { build, context } from 'esbuild';

const watch = process.argv.includes('--watch');

async function development() {
  const ctx = await context({
    entryPoints: ['./server/index.ts'],
    outfile: './dist/server/main.js',
    platform: 'node',
    target: 'es2020',
    minify: false,
    bundle: true,
    plugins: [
      {
        name: 'dev',
        setup(build) {
          build.onEnd(result => {
            if (result.errors.length > 0) {
              console.log(`Server build ended with ${result.errors.length} errors`);
              result.errors.forEach((error, i) => console.error(`Error ${i + 1}:`, error.text));
            } else {
              console.log('Successfully built server (development)');
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
    entryPoints: ['./server/index.ts'],
    outfile: './dist/server/main.js',
    platform: 'node',
    target: 'es2020',
    bundle: true,
    minify: true,
  })
    .then(() => {
      console.log('Successfully built server (production)');
    })
    .catch(error => {
      console.error('Failed building server (production):', error);
      process.exit(1);
    });
}

watch ? development() : production();
