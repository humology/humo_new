import esbuild from 'esbuild'
import { sassPlugin } from 'esbuild-sass-plugin'
import { sassLoadPaths, nodePaths } from './build.config.mjs'

const args = process.argv.slice(2)
const watch = args.includes('--watch')
const deploy = args.includes('--deploy')

const loader = {
    // Add loaders for images/fonts/etc, e.g. { '.svg': 'file' }
}

const plugins = [
    // Add and configure plugins here
    sassPlugin({ loadPaths: sassLoadPaths })
]

let opts = {
    entryPoints: ['js/app.js', 'css/app.scss'],
    bundle: true,
    target: 'es2017',
    outdir: '../priv/static/assets',
    logLevel: 'info',
    nodePaths: nodePaths,
    loader,
    plugins
}

if (watch) {
    opts = {
        ...opts,
        watch,
        sourcemap: 'inline'
    }
}

if (deploy) {
    opts = {
        ...opts,
        minify: true
    }
}

const promise = esbuild.build(opts)

if (watch) {
    promise.then(_result => {
        process.stdin.on('close', () => {
            process.exit(0)
        })

        process.stdin.resume()
    })
}
