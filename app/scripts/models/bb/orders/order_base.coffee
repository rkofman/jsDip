backbone = require 'backbone'
_ = require 'underscore'

module.exports = class OrderBase extends backbone.Model
  parse: (data, options) ->
    super.parse(...arguments) # TODO(rkofman): Write order-string parser.