angular.module("ffe").factory 'Category', ($resource, $rootScope) ->
  class Category
    constructor: (categoryId) ->
      endpoint = window.endpoint_to_url($('body').attr('categories_endpoint'))
      @service = $resource(endpoint+"/:id"
        { id: '@id' },
        { query: { method: "GET", isArray: false,  } })

    create: (attrs) ->
      new @service(category: attrs).$save (category) ->
        attrs.id = category.id
      attrs

    get: (id) ->
      @service.get(id: id, (data) ->
        $rootScope.$broadcast("category_loaded", data)
      )

    all: (cb) ->
      self = @

      @service.query( (data) ->
        self.firstCategoryId = data.categories[0].id
        self.brands     = data.categories.brands
        self.options    = data.options if data.options?
        self.scope      = data.scope if data.scope?
        self.collection = data.collection if data.collection?

        $rootScope.$broadcast("category_loaded", id: self.firstCategoryId)
      )

    firstCategoryId: ->
      @firstCategoryId

    brands: ->
      @brands