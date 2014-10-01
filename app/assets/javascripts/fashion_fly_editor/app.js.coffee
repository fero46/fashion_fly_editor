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

app.directive 'draggable', ->
  restrict:'A'
  link: (scope, element, attrs) ->
    element.draggable
      revert: true
      start: ->
        console.log "bar"

app.directive 'droppable', ($compile) ->
  link: (scope, element, attrs) ->
    element.droppable
      hoverClass: "drop-hover",
      drop: (e, ui) ->
        # check if newly added item
        if $(ui.draggable[0]).data('item')?
          item       = $(ui.draggable[0]).data('item')
          position_x = ui.offset.left - $(this).offset().left
          position_y = ui.offset.top - $(this).offset().top

          # create item on canvas
          el = angular.element "<div style='display: inline-block; top:#{position_y}px;left:#{position_x}px'><img src='#{item.image_url}' style='width:100%;height:100%' /></div>"
          el.draggable()
          el.rotatable()
          el.resizable
            aspectRatio: true
          element.append(el)

        else
          console.log "move me around"
          position_x = ui.offset.left - $(this).offset().left
          position_y = ui.offset.top - $(this).offset().top

        # debug info
        console.log position_x, position_y

app.config ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
