const { generateWebpackConfig, merge } = require('shakapacker')
const svelte = require('./loaders/svelte')

module.exports = merge(generateWebpackConfig(), {
  module: {
    rules: [svelte]
  },
  resolve: {
    alias: {
      '@components': 'app/javascript/components'
    },
    conditionNames: ['svelte', '...'],
    extensions: ['.svelte']
  }
})
