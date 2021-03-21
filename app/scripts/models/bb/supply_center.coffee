backbone = require 'backbone'

module.exports = class SupplyCenter extends backbone.Model
  initialize: ->
    super.initialize(...arguments)

  parse: (data, options) ->
    [x,y] = data.coords.split(',')
    {
      x: x
      y: y
      provinceName: data.provinceName
    }
