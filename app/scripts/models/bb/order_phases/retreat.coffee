BaseOrdersPhase = require './base'

Models = {
  Orders: {
    Move: require '../orders/move'
    Disband: require '../orders/disband'
  }
}

module.exports = class RetreatOrdersPhase extends BaseOrdersPhase
  type: "retreat"
  actionableProvinces: ->
    @get('country').get('units').where(disloged: true).map (unit) ->
      unit.get('province')
