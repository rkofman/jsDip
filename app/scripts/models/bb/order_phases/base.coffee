backbone = require 'backbone'


module.exports = class BaseOrderPhase extends backbone.Model

  actionableProvinces: ->
    throw "Each order-factory collection must implement this method."
