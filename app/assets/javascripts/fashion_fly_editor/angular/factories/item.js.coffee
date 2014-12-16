angular.module("ffe").factory 'Item', ($http) ->
  items: {}

  #helper
  itemsAsArray: ->
    self = @
    allItems = []
    $.each @items, (key, value) ->
#      self.items[key]['item_id'] = self.items[key]['id']
      # delete self.items[key]["id"]
      allItems.push self.items[key]
    allItems

  create: (scope) ->
    # we pass in controller scope for calling callback
    self = @
    self.scope = scope

    url = window.location.origin + window.location.pathname + '/collections'
    console.log(url)
    canvas_height = $('.ffe-editor__canvas').height()
    canvas_width = $('.ffe-editor__canvas').width()

    data =
      collection:
        title: scope.collection.title
        description: scope.collection.description
        collection_items_attributes: @itemsAsArray()
        height: canvas_height
        width: canvas_width

    # add config to data
    if scope.settings?
      data.redirect_url = scope.settings.config.collection.redirect_url

      # tbd: build items in rails instead, get rid of this bullshit
      options = {}
      values  = $('input[name^=options]')
      $.each values, (idx) =>
        item = $(values[idx])
        name = item.attr("name")
        name = name.replace("options[", "")
        name = name.replace("]","")
        options[name] = item.val()
      data.options = options

    $http(
      method: 'POST'
      url: url
      data: data
      dataType: 'JSON'
    ).success (data, status, headers, config) ->
      scope.collectionSuccessCallback(data, status) if self.scope?

    .error (data, status, headers, config) ->
      scope.collectionErrorCallback(data, status) if self.scope?

  get: (key) ->
    @items[key]

  add: (key, item) ->
    @update key, item

  update: (key, item) ->
    @items[key] = item

  delete: (key) ->
    delete @items[key]

  all: ->
    @items

  select: (key) ->
    @selected = @items[key]