angular.module("ffe").factory 'Collection', ($http, Item) ->
  collection:
    title: null
    price: null

  price: ->
    items = Item.all()
    price = 0
    $.each items, (key, value) ->
      price += parseFloat(items[key]["price"])
    price