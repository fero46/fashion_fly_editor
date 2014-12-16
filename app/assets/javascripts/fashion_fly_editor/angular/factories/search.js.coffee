angular.module("ffe").factory 'Search', ($resource, $rootScope) ->
  class Search
    constructor: () ->
      endpoint = window.endpoint_to_url($('body').attr('products_endpoint'))
      @service = $resource(endpoint+"/:id",
        { id: '@id'},
        { query: { method: "GET", isArray: false,  } })

    all: (params = {}) ->
      @service.query(params, (data) ->
        $rootScope.$broadcast("search_loaded", data)
      )