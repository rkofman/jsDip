BaseOrdersPhase = require './base'

Models = {
  Orders: {
    Disband: require '../orders/disband'
    Build: require '../orders/build'
  }
}

module.exports = class AdjustOrdersPhase extends BaseOrdersPhase
  type: "adjust"

  shouldBuild: ->
    @supplyCenterSurplus > 0

  shouldDisband: ->
    @supplyCenterSurplus < 0

  supplyCenterSurplus: ->
    @get('country').supplyCenters().count() - @get('country').get('unit').count()

