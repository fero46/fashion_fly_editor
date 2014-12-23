"use strict"

class HeadersController
  constructor: ($scope, $rootScope, Category, Settings) ->
    self = @
    $scope.inited = false
    category = new Category()
    $scope.categories = category.all()
    $scope.selected_id = 0
    # this is stupid, work with cb instead
    $scope.$on "category_loaded", (event, args) ->
      unless $scope.inited
        $('body').attr('init', 'stop')
        Settings.config.options    = category.options
        Settings.config.scope      = category.scope
        Settings.config.collection = category.collection
        $scope.inited= true
        $scope.selected_id = $scope.categories.categories[0].id
        $rootScope.$broadcast("select_main_category", id: $scope.selected_id)
        $('body').attr('can_resize', 'yes')
        $(window).resize( ->
          $scope.resizeView()
        )
        $scope.resizeView()
        $('body').fadeIn(100)

    $scope.isActive = (id) ->
      $scope.selected_id == id

    $scope.updateCategories = (id) ->
      $scope.selected_id = id
      $rootScope.$broadcast("select_main_category", id: id)
    $scope.resizeView = () ->
      if $('body').attr('can_resize') == 'yes'
        body_height = $(window).height()
        header_height = parseInt($('header').outerHeight(true),10);
        footer_height = parseInt($('footer').outerHeight(true),10);
        content_height = body_height - (header_height + footer_height)
        if content_height < 510
          content_height = 510
        $('.ffe-editor__wrapper').height(content_height)
        $('.ffe-editor__pane').height(content_height)
        # REPOSITION FOOTER
        $('footer').css('bottom', 'auto')
        $('footer').css('top',content_height+header_height)
        # CONTENT_AREA
        body_width = $(window).width()
        if body_width < 1170
          body_width = 1170

        canvas_width = body_width - $('.ffe-editor__pane').outerWidth(true) - 40
        $('.ffe-editor__wrapper').width(canvas_width)

        # Calculate inner Asspect Ratio
        width = 566
        height = 442;
        asspect_ratio = width / height
        # inner box with padding from canvas_wrapper
        inner_box_width = (canvas_width - 40)
        inner_box_height = (content_height - 68)

        outer_asspect_ratio = inner_box_width / inner_box_height
        if outer_asspect_ratio > asspect_ratio
          inner_box_width = asspect_ratio * inner_box_height
        else
          inner_box_height = inner_box_width / asspect_ratio

        $('.ffe-editor__canvas').width(inner_box_width)
        $('.ffe-editor__canvas').height(inner_box_height)

        $('.ffe-editor__canvas').css('top', (content_height - inner_box_height) / 2 )
        $('.ffe-editor__canvas').css('left', (canvas_width - inner_box_width) / 2 )

        #SIDEBAR
        navigation_tab = parseInt($('.navigation_tab').outerHeight(true),10)
        innerheight = content_height - navigation_tab
        $('.ff-tab-window').outerHeight(innerheight)
        # CATEGORY_TAB
        categories_height = parseInt($('.ff-tab_categories .ffe-categories').outerHeight(true),10)
        filters_height = parseInt($('.ff-tab_categories .ffe-filters').outerHeight(true),10)
        result_box_height = innerheight - (filters_height+categories_height)
        if result_box_height < 255
          result_box_height = 255
        $('.ff-tab_categories .ffe__items').outerHeight(result_box_height)
        # pagination arrows
        $('.ffe-pagination__previous').css('top', ((result_box_height/2) - $('.ffe-pagination__previous').outerHeight(true)) + "px")
        $('.ffe-pagination__next').css('top', ((result_box_height/2) - $('.ffe-pagination__next').outerHeight(true)) + "px")

        #container width
        $('.container').width($('.ff-tab-window').outerWidth + canvas_width)
        $('.container').height(content_height + footer_height + header_height);
        $rootScope.$broadcast("resize_finished", resize:'finished')
        if body_height < 550
          window.remove_padding = true

    $rootScope.$on('ngDialog.opened', (e, $dialog) ->
      if window.remove_padding
        $('.miyagi').attr('style', 'padding:0px !important')
      $('.btn').blur() # Fix bug
    )


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
          className: 'ngdialog-theme-plain miyagi'

      else
        # TODO: add route and template
        ngDialog.open
          controller: 'ActionsController'
          template: 'Bitte fügen Sie mindestens ein Element der Kollektion hinzu.'
          className: 'ngdialog-theme-plain miyagi'
          plain: true

    $scope.saveCollection = ($event) ->
      $event.preventDefault()
      $scope.form = {}
      $('.miyagi #information').show();
      $('.miyagi #formular').hide()
      Item.create($scope)

    $scope.collectionSuccessCallback = (data, status) ->
      window.location = data.location

    # called if creation fails
    $scope.collectionErrorCallback = (data, status) ->
      $scope.body = "Kollektion konnte nicht gespeichert werden."
      $scope.failure(data)
      $('.miyagi #information').hide();
      $('.miyagi #formular').show()

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
      $('body').attr('init', 'start')
      $scope.categories  = $scope.Category.get($scope.category_id)

    $scope.$on "update_category", (event, args) ->
      $scope.selectCategory(args.id)

    $scope.$on "category_loaded", (event, args) ->
      $scope.resetFilters()
      $scope.brands      = if args.brands? then args.brands else []
      $scope.colors      = if args.colors? then args.colors else []
      $scope.priceRanges = if args.price_ranges? then args.price_ranges else []
      if($('body').attr('init') == 'start' && $scope.categories.$resolved)
        $('body').attr('init', 'end')
        first = $scope.categories.categories[0].id
        $scope.selectCategory(first)

    $scope.$on "search_loaded", (event, args) ->
      $scope.pagination.update(args.pagination) if args.pagination?

    $scope.$on "resize_finished", (event, args) ->
      $scope.updateItems()

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
    #$scope.products = $scope.Search.all()

    $scope.resetFilter = (filter) ->
      switch filter
        when 'subcategory'
          $scope.filter_subcategory = null
        when 'brand'
          $scope.filter_brand = null
        when 'color'
          $scope.filter_color = null
        when 'priceRange'
          $scope.filter_priceRange = null
        else
          $scope.resetFilers()

      $scope.updateFilters()

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
        category: $scope.category_id,
        per: $scope.calculateTotalItemPerQuery()
      $scope.pagination.reset()
      $scope.products = $scope.Search.all(params)

    $scope.updateFilters = ->
      $scope.pagination.reset()
      $scope.updateItems()

    $scope.updateItems = ->
      params =
        name: if $scope.filter_name? then $scope.filter_name
        category: if $scope.filter_subcategory? && $scope.filter_subcategory.length > 0 then $scope.filter_subcategory[0].id else $scope.category_id
        brand: if $scope.filter_brand? && $scope.filter_brand.length > 0 then $scope.filter_brand[0].id
        color: if $scope.filter_color? && $scope.filter_color.length > 0 then $scope.filter_color[0].hex.split("#")[1]
        price: if $scope.filter_priceRange? && $scope.filter_priceRange.length > 0 then $scope.filter_priceRange[0].range
        page: if $scope.pagination.current_page? then $scope.pagination.current_page
        per: $scope.calculateTotalItemPerQuery()

      $scope.products = $scope.Search.all(params)

    $scope.calculateTotalItemPerQuery = ->
      parseInt($('.ff-tab_categories .ffe__items').height() / 92) * 3

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