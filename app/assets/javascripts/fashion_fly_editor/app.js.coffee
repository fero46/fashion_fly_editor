'use strict';


class HeadersController
  constructor: ($scope, $rootScope, Category) ->
    self = @

    category = new Category()
    $scope.categories = category.all()

    $scope.updateCategories = (id) ->
      $rootScope.$broadcast("update_category", id: id)

class ActionsController
  constructor: ($scope, Item) ->
    self = @

    $scope.saveCollection = ->
      console.log "saveCollection"
      Item.create()


class SidebarsController
  constructor: ($scope, Search, Category) ->
    self = @

    $scope.$on "update_category", (event, args) ->
      console.log "event: foo"
      $scope.selectCategory(args.id)

    categories = new Category()
    $scope.categories = categories.all()[0]

    sub_categories = new Category()
    $scope.sub_categories = {}

    search = new Search()
    $scope.products = search.all()

    # dummy filters, remove me
    $scope.category_id   = 1
    $scope.subcategories = ["Sub 1", "Sub 2"]
    $scope.brands        = ["Nike", "Puma"]
    $scope.colors        = ["#000", "#ff0000"]
    $scope.priceRanges    = ["0-50", "50-150", "150-250"]

    $scope.resetFilters = ->
      console.log "resetting filters"
      $scope.filter_subcategory = {}
      $scope.filter_brand       = {}
      $scope.filter_color       = {}
      $scope.filter_priceRange  = {}

    $scope.selectCategory = (id) ->
      console.log "selecting category #{id}"
      $scope.category_id = id
      $scope.updateItems()
      $scope.resetFilters() # maybe move into cb of updateItems

    $scope.selectProduct = (id) ->
      console.log "selecting product #{id}"

    $scope.updateItems = ->
      # use search service
      console.log "updating items based on filter"
      $scope.categories     = categories.get($scope.category_id)
      $scope.subcategories  = categories.get($scope.category_id)

app = angular.module('demo', ['ngResource'])

app.factory 'Item', ($http) ->
  items: {}

  #helper
  itemsAsArray: ->
    self = @
    allItems = []
    $.each @items, (key, value) ->
      # prepare Data
      self.items[key]['image'] = self.items[key]['image_url']
      self.items[key]['item_id'] = self.items[key]['id']

      delete self.items[key]['name']
      delete self.items[key]['id']
      delete self.items[key]['image_url']

      allItems.push self.items[key]
    allItems

  create: ->
    url = window.location.origin + window.location.pathname + '/collections'
    data = {
      collection: {
        collection_items_attributes: @itemsAsArray()
      }
    }

    $http(
      method: 'POST'
      url: url
      data: data
      dataType: 'JSON'
    ).success (data, status, headers, config) ->
      console.log "success"
    .error (data, status, headers, config) ->
      console.log "error"

  add: (key, item) ->
    @update key, item

  update: (key, item) ->
    @items[key] = item

  delete: (key) ->
    delete @items[key]

  all: ->
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
      #@service = $resource('/combine/api/v1/categories/:id',
      @service = $resource('http://localhost:3000/de/api/categories/:id'
        { id: '@id' },
        { query: { method: "GET", isArray: false,  } })

    create: (attrs) ->
      new @service(category: attrs).$save (category) ->
        attrs.id = category.id
      attrs

    get: (id) ->
      console.log id
      @service.get(id: id)

    all: ->
      @service.query()

app.controller("SidebarsController", ["$scope", "Search", "Category", SidebarsController])
app.controller("ActionsController", ["$scope", "Item", ActionsController])
app.controller("HeadersController", ["$scope", "$rootScope", "Category", HeadersController])

### DIRECTIVES ###

app.directive 'draggable', ->
  restrict:'A'
  link: (scope, element, attrs) ->
    element.draggable
      revert: true

app.directive 'droppable', ['$compile', 'Item', ($compile, Item) ->
  items = Item
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
          el = angular.element "<div id='item_#{key}' style='display: inline-block; position: absolute; top:#{position_y}px;left:#{position_x}px'><div class='item__remove'>x</div><img src='#{item.image_url}' style='width:100%;height:100%' /></div>"
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
          item['height']     = el.height()
          items.add key, item

          # add remove item
          element.find('.item__remove').on 'click', (e) =>
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
  #authToken = $("meta[name=\"csrf-token\"]").attr("content")
  #$httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
  $httpProvider.defaults.headers.common["Accept"] = 'application/json'
