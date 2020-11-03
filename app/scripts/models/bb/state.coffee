backbone = require 'backbone'
_ = require 'underscore'

Collections = {
  Countries: require '../../collections/countries.coffee'
}

Models = {
  OrderPhases: {
    Adjust: require './order_phases/adjust.coffee'
    Movement: require './order_phases/movement.coffee'
    Retreat: require './order_phases/retreat.coffee'
  }
}

module.exports = class State extends backbone.Model
  parse: (data, options) ->
    _(super).tap (attrs) =>
      countries = _(attrs.countries).map (val, key) =>
        _(val).extend name: key
      attrs.countries = new Collections.Countries(
        countries
        state: @
        phase: attrs.phase
        allProvinces: options.provinces
        parse: true
      )

  activeCountries: ->
    @get('countries').active()

  getCountry: (name) ->
    @get('countries').get name

  units: ->
    @get('countries').units()

  startOrderEntry: (countryName) ->
    country = @getCountry(countryName)

    orderPhase = Models.OrderPhases[@get('phase')]
    throw "Can't parse phase." unless orderPhase
    @set('ordersPhase', new orderPhase(country: country))
