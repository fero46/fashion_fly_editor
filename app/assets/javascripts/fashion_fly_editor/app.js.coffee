'use strict';

class SidebarsController
  constructor: ($scope, Search, Category) ->
    self = @

    categories = new Category()
    $scope.categories = categories.all()

    search = new Search()
    $scope.products = search.all()

    $scope.selectCategory = (id) ->
      console.log "selecting category #{id}"

    $scope.selectProduct = (id) ->
      console.log "selecting product #{id}"

app = angular.module('demo', ['ngResource'])

app.factory 'Item', ($resource) ->
  class Item
    constructor: () ->
      @items = {}
      @service = $resource('/combine/api/v1/collection_items/:id',
        { id: '@id'})

    add: (key, item) ->
      @items[key] = item

    update: (key, item) ->
      @items[key] = item

    delete: (key) ->
      delete @items[key]

    all: ->
      #@service.query()
      @items

app.factory 'Search', ($resource) ->
  class Search
    constructor: () ->
      @service = $resource('/combine/api/v1/search/:id',
        { id: '@id'})

    all: ->
      @service.query()

app.factory 'Category', ($resource) ->
  class Category
    constructor: (categoryId) ->
      @service = $resource('/combine/api/v1/categories/:id',
        { id: '@id'})

    create: (attrs) ->
      new @service(category: attrs).$save (category) ->
        attrs.id = category.id
      attrs

    all: ->
      @service.query()

app.controller("SidebarsController", ["$scope", "Search", "Category", SidebarsController])

### DIRECTIVES ###

app.directive 'draggable', ->
  restrict:'A'
  link: (scope, element, attrs) ->
    element.draggable
      revert: true

app.directive 'droppable', ['$compile', 'Item', ($compile, Item) ->
  items = new Item()
  link: (scope, element, attrs) ->
    element.droppable
      hoverClass: "drop-hover",
      drop: (e, ui) ->
        self = @

        # check if newly added item
        if $(ui.draggable[0]).data('item')?
          item       = $(ui.draggable[0]).data('item')
          position_x = ui.offset.left - $(this).offset().left
          position_y = ui.offset.top - $(this).offset().top

          # random key for element
          key = Math.random().toString(36).replace(/[^a-z]+/g, '')

          # create item on canvas
          el = angular.element "<div id='item_#{key}' style='display: inline-block; top:#{position_y}px;left:#{position_x}px'><div class='item__remove'>x</div><img src='#{item.image_url}' style='width:100%;height:100%' /></div>"
          el.draggable
            stop: (e, ui) ->
              item['position_x'] = ui.position.left
              item['position_y'] = ui.position.top
              items.update key, item

          el.rotatable
            stop: (e, ui) ->
              deg = ui.angle.stop * (180/3.14159265) # convert radian to degrees
              item['rotation'] = deg
              items.update key, item

          el.resizable
            aspectRatio: true
            stop: (e, ui) ->
              item['width']  = ui.size.width
              item['height'] = ui.size.height
              items.update key, item

          element.append(el)

          # set initial values for item and add to collection
          item['position_x'] = position_x
          item['position_y'] = position_y
          item['rotation']   = 0
          item['width']      = el.width()
          item['height']      = el.height()
          items.add key, item

          # add remove item
          element.find('.item__remove').on 'click', (e) =>
            console.log 'remove item'
            $el = $(e.currentTarget).parent()
            items.delete $el.attr('id').split('_')[1]
            $el.remove()

        else
          console.log "move me around"
          position_x = ui.offset.left - $(this).offset().left
          position_y = ui.offset.top - $(this).offset().top

        # debug info
        console.log items.all()
        console.log position_x, position_y
]

### CONFIG ###

app.config ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
