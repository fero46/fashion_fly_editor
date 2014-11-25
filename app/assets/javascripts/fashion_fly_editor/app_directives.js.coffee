"use strict"

angular.module("ffe").directive 'draggable', ->
  restrict:'A'
  link: (scope, element, attrs) ->
    element.draggable
      helper: 'clone'

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
          delete item["id"]
          position_x = ui.offset.left
          position_y = ui.offset.top

          # random key for element
          key = Math.random().toString(36).replace(/[^a-z]+/g, '')

          # create item on canvas
          image = $("<img style='width:100%;height:100%'>")
          image.attr('src', item.image)
          el    = angular.element "<div class='ffe-item' id='ffe-item_#{key}' style='width: #{item.width}px; height: #{item.height}px; position: absolute; top:#{position_y}px;left:#{position_x}px'><div class='ffe-item__remove'>x</div></div>"
          el.prepend(image)

          flip = $("<div class='ffe-item__flip'>")
          el.append(flip)
          flop = $("<div class='ffe-item__flop'>")
          el.append(flop)

          # includes fix for jumping on dragging with css transforms
          # http://stackoverflow.com/questions/3523747/webkit-and-jquery-draggable-jumping
          recoupLeft = 0
          recoupTop = 0
          el.draggable
            start: (e, ui) ->
              # make active on drag
              $('.ffe-item').removeClass('active')
              el.addClass('active')

              left = parseInt($(this).css('left'),10)
              left = if isNaN(left) then 0 else left
              top = parseInt($(this).css('top'),10)
              top = if isNaN(top) then 0 else top
              recoupLeft = left - ui.position.left
              recoupTop = top - ui.position.top

            drag: (e, ui) ->
              ui.position.left += recoupLeft
              ui.position.top  += recoupTop

            stop: (e, ui) ->
              item['position_x'] = ui.position.left - $('.ffe-editor__canvas').offset().left
              item['position_y'] = ui.position.top - $('.ffe-editor__canvas').offset().top
              items.update key, item

          el.resizable
            aspectRatio: true
            handles: "n, e, s, w, ne, se, sw, nw"
            stop: (e, ui) ->
              item['width']  = ui.size.width
              item['height'] = ui.size.height
              items.update key, item

          el.rotatable
            stop: (e, ui) ->
              deg = ui.angle.stop * (180/3.14159265) # convert radian to degrees
              item['rotation'] = deg
              items.update key, item

          el.on 'click', (e) ->
            $('.ffe-item').removeClass('active')
            $(e.currentTarget).addClass('active')


          # make active on load
          $('.ffe-item').removeClass('active')
          el.addClass('active')

          element.append(el)

          # set initial values for item and add to collection
          item['position_x'] = position_x - $('.ffe-editor__canvas').offset().left
          item['position_y'] = position_y - $('.ffe-editor__canvas').offset().top
          item['rotation']   = 0
          item['width']      = el.width()
          item['height']     = el.height()
          item['scale_x']    = 1
          item['scale_y']    = 1
          items.add key, item

          # add remove item
          element.find('.ffe-item__remove').on 'click', (e) ->
            $el = $(e.currentTarget).parent()
            items.delete $el.attr('id').split('_')[1]
            $el.remove()

          # add flip_x
          element.find('.ffe-item__flip').on 'click', (e) ->
            $el = $(e.currentTarget).parent()
            if $el.hasClass("flip")
              $el.removeClass("flip")
              item.scale_x = 1
            else
              $el.addClass("flip")
              item.scale_x = -1

          element.find('.ffe-item__flop').on 'click', (e) ->
            $el = $(e.currentTarget).parent()
            if $el.hasClass("flop")
              $el.removeClass("flop")
              item.scale_y = 1
            else
              $el.addClass("flop")
              item.scale_y = -1

        else
          console.log "move me around"
          position_x = ui.offset.left - $(this).offset().left
          position_y = ui.offset.top - $(this).offset().top

        # debug info
        console.log items.all()

  dir
]