"use strict"

angular.module("ffe").directive 'draggable', ->
  restrict:'A'
  link: (scope, element, attrs) ->
    element.draggable
      revert: true

angular.module("ffe").directive 'droppable', ['$compile', 'Item', 'Collection', ($compile, Item, Collection) ->
  items = Item
  dir   =     {}

  dir.restrict = 'A'
  dir.link = (scope, element, attrs) ->
    self = @

    element.droppable
      hoverClass: "drop-hover",
      drop: (e, ui) ->

        # check if newly added item
        if $(ui.draggable[0]).data('item')?
          item       = $(ui.draggable[0]).data('item')
          position_x = ui.offset.left
          position_y = ui.offset.top

          # random key for element
          key = Math.random().toString(36).replace(/[^a-z]+/g, '')

          # create item on canvas
          el = angular.element "<div id='ffe-item_#{key}' style='display: inline-block; position: absolute; top:#{position_y}px;left:#{position_x}px'><div class='item__remove'>x</div><img src='#{item.image}' style='width:100%;height:100%' /></div>"

          el.draggable
            stop: (e, ui) ->
              item['position_x'] = ui.position.left - $('.ffe-editor__canvas').offset().left
              item['position_y'] = ui.position.top - $('.ffe-editor__canvas').offset().top
              items.update key, item

          el.resizable
            aspectRatio: true
            stop: (e, ui) ->
              item['width']  = ui.size.width
              item['height'] = ui.size.height
              items.update key, item

          el.rotatable
            stop: (e, ui) ->
              deg = ui.angle.stop * (180/3.14159265) # convert radian to degrees
              item['rotation'] = deg
              items.update key, item

          element.append(el)

          # set initial values for item and add to collection
          item['position_x'] = position_x - $('.ffe-editor__canvas').offset().left
          item['position_y'] = position_y - $('.ffe-editor__canvas').offset().top
          item['rotation']   = 0
          item['width']      = el.width()
          item['height']     = el.height()
          items.add key, item

          # add remove item
          element.find('.item__remove').on 'click', (e) ->
            $el = $(e.currentTarget).parent()
            console.log key
            items.delete $el.attr('id').split('_')[1]
            $el.remove()

        else
          console.log "move me around"
          position_x = ui.offset.left - $(this).offset().left
          position_y = ui.offset.top - $(this).offset().top

        # debug info
        console.log items.all()

  dir
]