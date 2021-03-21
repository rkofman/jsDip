_ = require 'underscore'
backbone = require 'backbone'

Views = {
  BaseSvgView: require '../base_svg'
}

module.exports = class Hold extends Views.BaseSvgView

  tagName: 'use'
  xlink: {
    href: "#hold-icon"
  }
  className: "hold-icon"

  initialize: ->
    super.initialize(...arguments)

  render: ->
    coords = @model.get('province').get('unitCoordinates')
    @$el.attr('transform', "translate(#{coords.x},#{coords.y})")
