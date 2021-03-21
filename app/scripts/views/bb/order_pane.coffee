Views = {
  Base: require './base'
  OrderPaneOrder: require './order_pane_order'
  CollectionView: require './collection_view'
}

module.exports = class OrderPane extends Views.Base
  el: '#sidebar'

  initialize: ->
    super.initialize(...arguments)
    
  render: ->
    @listenTo(@model, 'change:ordersPhase', @redraw)
    @redraw()
    super.render(...arguments)

  redraw: ->
    @collectionView?.remove()
    @collectionView = new Views.CollectionView(
      tagName: 'ul'
      className: 'order-pane'
      collection: @model?.get('ordersPhase')?.get('orders'),
      subView: Views.OrderPaneOrder)
    @collectionView.render()
    @$el.append @collectionView.el
