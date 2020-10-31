OrderBase = require './order_base'
Models = {
  Orders: {
    Move: require './move'
  }
}
module.exports = class SupportOrder extends OrderBase


  parse: (text, options) ->
    provinces = options.provinces
    orderParser = options.orderParser

    match = text.match(/^([AF]) (.+?) (supports|supp|support) (.+)$/i) # case insensitive!
    throw new Error("Can't parse order text: `#{text}`") unless match
    @_unitType = match[1]
    try
      @set('subOrder', orderParser.parse(match[4]))
    catch e
      throw new Error("Can't parse Support sub-order: `#{match[4]}`. Original exception: #{e}")
    if @get('subOrder').type() not in ['move', 'hold']
      throw new Error("Can't parse Support sub-order. Only 'move' and 'hold' types are allowed. Got: #{@get('subOrder').type()})")
    {
      province: provinces.get(match[2])
    }
      

  sourceProvinceName: ->
    @get('subOrder').provinceName()

  provinceName: () ->
    @get('province').get('name')

  targetProvinceName: ->
    @get('subOrder').targetProvinceName()

  unitType: () ->
    @_unitType

  toJSON: () ->
    "#{@unitType()} #{@provinceName()} Supports #{@get('subOrder').toJSON()}"

  pushProvince: (province) ->
    if !@get('subOrder')
      @set('province', province)
      # WARNING: this is a bug. The UI should choose what kind of order
      # this is going to build. Perhaps "Hold". Alternatively, can be based on 
      # target + destination being the same -- in either case, the blow line
      # of code is.. incorrect.
      @set('subOrder', new Models.Orders.Move())
      @listenTo(@get('subOrder'), 'construction:complete', @onSubOrderComplete)
    else
      @get('subOrder').pushProvince(province)

  validNextProvinces: ->
    # TODO next: All provinces that have units.

  onSubOrderComplete: ->
    @trigger('construction:complete')

  type: ->
    module.exports.type

module.exports.type = "support"
module.exports.displayName = "Support"
