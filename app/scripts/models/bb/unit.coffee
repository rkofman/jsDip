backbone = require 'backbone'
_ = require 'underscore'

module.exports = class Unit extends backbone.Model
  # Expected attributes:
  #   type: 'fleet' / 'army'
  #   province: vivified Province model
  #   owner: vivified Country model

  sphereOfInfluence: ->
    if @get('type') == 'army'
      @get('province').getAdjacentForArmies()
    else if @get('type') == 'fleet'
      @get('province').getAdjacentForFleets()
  
  occupiedSphereOfInfluence: ->
    _(@sphereOfInfluence().select((province) -> province.get('unit')))

  unOccupiedSphereOfInfluence: ->
    _(@sphereOfInfluence().select((province) -> province.get('unit')))