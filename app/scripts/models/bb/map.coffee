backbone = require 'backbone'

module.exports = class Map extends backbone.Model
  initialize: ->
    super.initialize(...arguments)

  parse: (date, options) ->
    super.parse(...arguments)
