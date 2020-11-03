backbone = require 'backbone'
BaseOrdersPhase = require './base'

OrderClasses = [
  # order of array is the order in which they will be displayed in the selector UI
  require '../orders/move'
  require '../orders/hold'
  require '../orders/support'
  require '../orders/convoy'
]

module.exports = class MovementOrdersPhase extends BaseOrdersPhase
  orderClasses: OrderClasses

  initialize: (attrs, options) ->
    @orderUnderConstruction = null
    @pendingProvince = null
    @set('actionableProvinces', @initiallyActionableProvinces())
    @set('orders', attrs.country.get('orders'))

  initiallyActionableProvinces: ->
    provincesArr = @get('country').get('units').map (unit) ->
      unit.get('province')
    new backbone.Collection(provincesArr)

  actionableProvinces: ->
    if @orderUnderConstruction
      @orderUnderConstruction.validNextProvinces()
    else
      @initiallyActionableProvinces()

  hasOrderUnderConstruction: ->
    !!@orderUnderConstruction

  pushOrderClass: (orderClass) ->
    @orderUnderConstruction = new orderClass()
    @listenTo(@orderUnderConstruction, 'construction:complete', @onConstructionComplete)
    @pushProvince(@pendingProvince) # potential infinite loop. maybe cleanup this code.
    @pendingProvince = null

  onConstructionComplete: ->
    @dedupExisting(@orderUnderConstruction)
    @get('orders').push @orderUnderConstruction
    @orderUnderConstruction = null
    @pendingProvince = null # probably not necessary.

  dedupExisting: (order) ->
    dupe = @get('orders').where({province: order.get('province')})
    @get('orders').remove(dupe)


  # note: this seems like an unnecessary level of indirection
  # perhaps the view should just ask for an order object to interact with
  # and push directly to it?
  pushProvince: (province) ->
    if @orderUnderConstruction
      @orderUnderConstruction.pushProvince(province)
      @updateActionable()
    else
      @pendingProvince = province

  updateActionable: ->
    if @orderUnderConstruction
      @set('actionableProvinces', @orderUnderConstruction.validNextProvinces())
    else
      @set('actionableProvinces', @initiallyActionableProvinces())
