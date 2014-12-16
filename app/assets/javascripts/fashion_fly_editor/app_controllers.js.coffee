"use strict"

class HeadersController
  constructor: ($scope, $rootScope, Category, Settings) ->
    self = @

    $scope.inited = false

    category = new Category()
    $scope.categories = category.all()

    # this is stupid, work with cb instead
    $scope.$on "category_loaded", (event, args) ->
      unless $scope.inited
        Settings.config.options    = category.options
        Settings.config.scope      = category.scope
        Settings.config.collection = category.collection
        $scope.inited= true
        $rootScope.$broadcast("select_main_category", id: $scope.categories.categories[0].id)
        $('body').fadeIn(100)

    $scope.updateCategories = (id) ->
      $rootScope.$broadcast("select_main_category", id: id)

class ActionsController
  constructor: ($scope, Item, Collection, Settings, ngDialog) ->
    self = @

    $scope.settings = Settings
    $scope.baseUrl  = window.location.origin + window.location.pathname + '/collections'

    $scope.collection = Collection
    $scope.form = {}
    $scope.collection.title = undefined
    $scope.title = "Kollektion speichern"
    $scope.body  = "Nur noch wenige Schritte."

    $scope.presaveCollection = ->
      if $.map(Item.all(), (n, i) -> return i).length > 0
        # put options in params
        $scope.params = $.param($scope.settings.config)

        ngDialog.open
          controller: 'ActionsController'
          template: $scope.baseUrl + '/new?' + $scope.params
          className: 'ngdialog-theme-plain'

      else
        # TODO: add route and template
        ngDialog.open
          controller: 'ActionsController'
          template: 'Bitte fügen Sie mindestens ein Element der Kollektion hinzu.'
          className: 'ngdialog-theme-plain'
          plain: true

    $scope.saveCollection = ($event) ->
      $event.preventDefault()
      $scope.form = {}
      Item.create($scope)

    $scope.collectionSuccessCallback = (data, status) ->
      window.location = data.location

    # called if creation fails
    $scope.collectionErrorCallback = (data, status) ->
      $scope.body = "Kollektion konnte nicht gespeichert werden."
      $scope.failure(data)

    $scope.failure = (response) ->
      $.each response, (key, errors) ->
        $.each errors, (k, e) ->
          $scope.form[key] ||= {}
          $scope.form[key].$dirty = true
          $scope.form[key].$invalid = true
          $scope.form[key].errors ||= []
          $scope.form[key].errors.push(e)

    $scope.errorMessage = (name) ->
      result = []
      if $scope.form[name]?
        $.each $scope.form[name].errors, (key, value) ->
          result.push(value)
        result.join(", ")

    $scope.errorClass = (name) ->
      s = $scope.form
      if s?
        s = s[name]
        if s? && s.$invalid && s.$dirty then "error" else ""

class MainController
  constructor: ($scope, Search, Category, Collection, Item) ->
    self = @

    # events
    $scope.$on "select_main_category", (event, args) ->
      $scope.category_id = args.id
      $scope.categories  = $scope.Category.get($scope.category_id)

    $scope.$on "update_category", (event, args) ->
      $scope.selectCategory(args.id)

    $scope.$on "category_loaded", (event, args) ->
      $scope.resetFilters()
      $scope.brands      = if args.brands? then args.brands else []
      $scope.colors      = if args.colors? then args.colors else []
      $scope.priceRanges = if args.price_ranges? then args.price_ranges else []

    $scope.$on "search_loaded", (event, args) ->
      $scope.pagination.update(args.pagination) if args.pagination?

    $scope.isActive = (category_id) ->
      $scope.category_id == category_id

    $scope.selectedItem = ->
      item = Item.selected || undefined
      if item?
        "#{item.name}, #{parseFloat(item.price).toFixed(2)}"

    # search
    $scope.searchTerm = null # tmp holds search term
    $scope.search = ->
      $scope.category_id = undefined
      $scope.resetFilters()
      $scope.filter_name = $scope.searchTerm
      $scope.updateItems()

    # init tabs
    $scope.tabs =
      selected: 1
      selectTab: (setTab) ->
        this.selected = setTab
        if this.selected == 1
          $scope.filter_name = null # reset search, we always want items
          $scope.updateItems()

        if this.selected == 2 # show search, based on prev search
          $scope.search()

      isSelected: (checkTab) ->
        this.selected == checkTab

    # init Pagination Object
    $scope.pagination =
      current_page: null
      total_pages: null
      first_page: null
      last_page: null
      total_count: null
      paginate: ($event, page) ->
        $event.preventDefault()
        @current_page = page
        $scope.updateItems()
      update: (vals) ->
        @current_page = vals.current_page
        @total_pages  = vals.total_pages
        @first_page   = vals.first_page
        @last_page    = vals.last_page
        @total_count  = vals.total_count
      reset: ->
        @current_page = null
        @total_pages  = null
        @first_page   = null
        @last_page    = null
        @total_count  = null

    # init Categories and Search
    $scope.Category = new Category()

    $scope.Search = new Search()
    $scope.products = $scope.Search.all()

    $scope.resetFilters = ->
      $scope.filter_name        = null
      $scope.filter_subcategory = null
      $scope.filter_brand       = null
      $scope.filter_color       = null
      $scope.filter_priceRange  = null

    $scope.resetItems = ->
      $scope.brands = []
      $scope.colors = []
      $scope.priceRanges = []
      $scope.subcategories = []

    $scope.selectCategory = (id) ->
      $scope.category_id   = id
      $scope.subcategories = $scope.Category.get($scope.category_id)
      params =
        category: $scope.category_id

      $scope.pagination.reset()
      $scope.products = $scope.Search.all(params)

    $scope.updateFilters = ->
      $scope.pagination.reset()
      $scope.updateItems()

    $scope.updateItems = ->
      params =
        name: if $scope.filter_name? then $scope.filter_name
        category: if $scope.filter_subcategory? then $scope.filter_subcategory.id else $scope.category_id
        brand: if $scope.filter_brand? then $scope.filter_brand.id
        color: if $scope.filter_color? then $scope.filter_color.hex.split("#")[1]
        price: if $scope.filter_priceRange? then $scope.filter_priceRange.range
        page: if $scope.pagination.current_page? then $scope.pagination.current_page

      $scope.products = $scope.Search.all(params)

    $scope.collection = Collection
    $scope.collectionMetaInformation = ->
      price = $scope.collection.price()
      if price? && price != 0
        return price.toFixed(2)
      else
        return false

    $scope.collectionItemCount = ->
      items = Item.all()
      # think not supported in ie8
      Object.keys(items).length

angular.module("ffe.controllers", [])
.controller("MainController", ["$scope", "Search", "Category", "Collection", "Item", MainController])
.controller("ActionsController", ["$scope", "Item", 'Collection', 'Settings', 'ngDialog', ActionsController])
.controller("HeadersController", ["$scope", "$rootScope", "Category", "Settings", HeadersController])