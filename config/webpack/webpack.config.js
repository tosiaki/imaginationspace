const { merge, webpackConfig } = require('shakapacker')
const svelte = require('./loaders/svelte')

module.exports = merge(webpackConfig, {
  module: {
    rules: [svelte]
  },
  resolve: {
    alias: {
      '@components': 'app/javascript/components'
    },
    extensions: ['.svelte']
  }
})
