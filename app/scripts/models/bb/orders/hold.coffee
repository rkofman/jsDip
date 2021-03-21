module.exports = {}
OrderBase = require './order_base'
module.exports = class HoldOrder extends OrderBase
  parse: (text, options) ->
    provinces = options.provinces

    match = text.match(/([AF]) (.+?) (HOLD|H)/i) # case insensitive!
    throw new Error("Can't parse order text: `#{text}`") unless match
    @_unitType = match[1]
    {
      province: provinces.get(match[2])
    }

  provinceName: () ->
    @get('province').get('name')

  unitType: () ->
    # TODO(rkofman): parse / serialize from tests doesn't
    # play nice with statefulness of board. That's ugly.
    #
    # perhaps an order should know about the theoretical unit being ordered,
    # even if such a unit doesn't exist on the board? In case of real game, that unit
    # can be copied from the board. In others, it can be generated just for
    # use with the order itself? Should same apply to provinces? Not really
    # sure about this direction yet.
    @get('province')?.get('unit')?.get('type')[0].toUpperCase() || @_unitType

  toJSON: () ->
    "#{@unitType()} #{@provinceName()} Hold"

  type: ->
    module.exports.type

  pushProvince: (province) ->
    @set('province', province)
    @trigger('construction:complete')


module.exports.type = "hold"
module.exports.displayName = "Hold"
