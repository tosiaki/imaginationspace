const { environment } = require('@rails/webpacker')
// const baseConfig = require('./base')
const svelte = require('./loaders/svelte')

environment.loaders.prepend('svelte', svelte)
// environment.config.merge(baseConfig)
module.exports = environment
