const { environment } = require('@rails/webpacker')
// const baseConfig = require('./base')
const svelte = require('./loaders/svelte')

environment.loaders.prepend('svelte', svelte)

// Webpacker's legacy compression plugins hard-code OpenSSL's removed MD4
// digest. Asset compression belongs at the HTTP layer, so omit the duplicate
// precompressed files instead of enabling Node's legacy crypto provider.
if (process.env.NODE_ENV === 'production') {
  environment.plugins.delete('Compression')
  environment.plugins.delete('Compression Brotli')
}

// environment.config.merge(baseConfig)
module.exports = environment
