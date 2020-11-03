OrderBase = require './order_base'
Models = {
  Orders: {
    Move: require './move'
    Hold: require './hold'
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
    @get('province')?.get('unit')?.get('type')[0].toUpperCase() || @_unitType

  toJSON: () ->
    if @get('subOrder')
      "#{@unitType()} #{@provinceName()} Supports #{@get('subOrder').toJSON()}"
    else
      "#{@unitType()} #{@provinceName()} Supports ???"

  pushProvince: (province) ->
    if !@get('province')
      @set('province', province)
    else if !@get('source')
      @set('source', province)
    else
      @createSubOrder(province)
      @trigger('construction:complete')
  
  createSubOrder: (finalProvince) ->
    if @get('source') == finalProvince
      # create support sub-order
      hold = new Models.Orders.Hold()
      hold.pushProvince(finalProvince)
      @set('subOrder', hold)
    else
      # create movement sub-order
      move = new Models.Orders.Move()
      move.pushProvince(@get('source'))
      move.pushProvince(finalProvince)
      @set('subOrder', move)

  validNextProvinces: ->
    if !@get('source') 
      @validSupportableProvinces()
    else
      @validSupportDestinations()

  validSupportableProvinces: ->
    _(@unit().occupiedSphereOfInfluence().chain()
    .map((province) -> province.get('unit'))
    .map((unit) -> unit.sphereOfInfluence())
    .map((underscoreWrapper) -> underscoreWrapper.value())
    .flatten()
    .uniq()
    .without(@get('province'))
    .value())
  
  validSupportDestinations: ->
    _(@get('source').get('unit').sphereOfInfluence().chain()
    .push(@get('source'))
    .intersection(@unit().sphereOfInfluence().values())
    .value())

  unit: ->
    @get('province').get('unit')

  onSubOrderComplete: ->
    @trigger('construction:complete')

  type: ->
    module.exports.type

module.exports.type = "support"
module.exports.displayName = "Support"
