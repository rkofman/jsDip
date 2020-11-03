module.exports = {}
OrderBase = require './order_base'
module.exports = class MoveOrder extends OrderBase

  parse: (text, options) ->
    provinces = options.provinces

    match = text.match(/([AF]) (.+?) (move|->|-) (.+)/i) # case insensitive!
    throw new Error("Can't parse order text: `#{text}`") unless match
    @_unitType = match[1]
    # note: we should likely re-use the pushProvince method -- but it requires
    # a full / vivified province. There should *not* be two ways to initialize this class.
    # alternatively: we can remove the vivified classes; and make this a simple data container;
    # which relies on a global State singleton to do its work navigating the world.
    {
      province: provinces.get(match[2])
      targetProvince: provinces.get(match[4])
    }

  provinceName: () ->
    @get('province').get('name')

  targetProvinceName: ->
    @get('targetProvince').get('name')

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
    "#{@unitType()} #{@provinceName()} -> #{@targetProvinceName()}"

  type: ->
    module.exports.type

  pushProvince: (province) ->
    if @get('province')
      @set('targetProvince', province)
      @trigger('construction:complete')
    else
      @set('province', province)

  validNextProvinces: ->
    # note: unit should become first order attribute. Law of Demeter.
    @get('province').get('unit').sphereOfInfluence()

module.exports.type = "move"
module.exports.displayName = "Move"
