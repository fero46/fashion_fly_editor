"use strict"

angular.module("ffe").directive 'draggable', ->
  restrict:'A'
  link: (scope, element, attrs) ->
    element.draggable
      helper: 'clone'

angular.module("ffe").directive 'droppable', ['$compile', 'Item', 'Collection', ($compile, Item, Collection) ->
  items = Item
  dir   = {}

  dir.childOffset = ->
    wrapper = $('.ffe-editor__wrapper').offset();
    canvas = $('.ffe-editor__canvas').offset();
    return {
      top: canvas.top - wrapper.top,
      left: canvas.left - wrapper.left
    }

  dir.restrict = 'A'
  dir.link = (scope, element, attrs) ->
    dir.scope = scope

    dir.getInitialImageDimensions = (item, maxWidth = 200, maxHeight = 200) ->
      size = {}
      ratio = item.width / item.height
      if ratio > 1 && item.width > maxWidth
        ratio = maxWidth / item.width
        size.width = maxWidth
        size.height = item.height * ratio
      else if ratio < 1 && item.height > maxHeight
        ratio = maxHeight / item.height
        size.width = item.width * ratio
        size.height = maxHeight
      else
        size.width = item.width
        size.height = item.height
      size

    element.droppable
      hoverClass: "drop-hover",
      drop: (e, ui) ->
        # check if newly added item
        if $(ui.draggable[0]).data('item')?
          item       =  jQuery.extend(true, {}, $(ui.draggable[0]).data('item'));
          position_x = ui.offset.left - $('.ffe-editor__wrapper').offset().left
          position_y = ui.offset.top - $('.ffe-editor__wrapper').offset().top

          initial_size = dir.getInitialImageDimensions(item)
          initial_width = initial_size.width;
          initial_height = initial_size.height;

          # random key for element
          key = Math.random().toString(36).replace(/[^a-z]+/g, '')

          # create item on canvas
          image = $("<img style='width:100%;height:100%'>")
          image.attr('src', item.image)
          el    = angular.element "<div class='ffe-item' id='ffe-item_#{key}' style='width: #{initial_width}px; height: #{initial_height}px; position: absolute; top:#{position_y}px;left:#{position_x}px'></div>"
          el.prepend(image)
          # create z-index
          new_index = parseInt($('.ffe-editor__wrapper').attr('highest_index')) + 1
          $('.ffe-editor__wrapper').attr('highest_index', new_index)
          el.css('z-index', new_index)
          $('.ffe-editor__meta').css('z-index', new_index + 1)

          # remove
          remove = $("<div class='ffe-item__remove'>x</div>")
          el.append(remove)
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
              Item.select(key)
              dir.scope.$apply()

              left = parseInt($(this).css('left'),10)
              left = if isNaN(left) then 0 else left
              top = parseInt($(this).css('top'),10)
              top = if isNaN(top) then 0 else top
              recoupLeft = left - ui.position.left
              recoupTop = top - ui.position.top

            drag: (e, ui) ->
              ui.position.left += recoupLeft
              ui.position.top  += recoupTop

            stop: (e, ui) =>
              item['position_x'] = ui.position.left - dir.childOffset().left
              item['position_y'] = ui.position.top - dir.childOffset().top
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
            e.stopPropagation()
            if(!$(e.currentTarget).hasClass('active'))
              $('.ffe-item').removeClass('active')
              $(e.currentTarget).addClass('active')
              items.select(key)
              dir.scope.$apply()
              new_index = parseInt($('.ffe-editor__wrapper').attr('highest_index')) + 1
              $('.ffe-editor__wrapper').attr('highest_index', new_index)
              $(e.currentTarget).css('z-index', new_index)
              $('.ffe-editor__meta').css('z-index', new_index + 1)
              item['order'] = new_index

          # make active on load
          $('.ffe-item').removeClass('active')
          el.addClass('active')

          element.append(el)

          # set initial values for item and add to collection
          item['position_x'] = position_x - dir.childOffset().left
          item['position_y'] = position_y - dir.childOffset().top
          item['rotation']   = 0
          item['width']      = initial_width
          item['height']     = initial_height
          item['scale_x']    = 1
          item['scale_y']    = 1
          item['item_id']    = item.id
          item['id'] = key
          item['order']   = new_index
          items.add key, item
          window.items = items
          # add remove item
          element.find('.ffe-item__remove').off('click').on 'click', (e) =>
            $el = $(e.currentTarget).parent()
            items.delete $el.attr('id').split('_')[1]
            $el.remove()
            items.selected = undefined
            dir.scope.$apply()

          # add flip_x
          element.find('.ffe-item__flip').off('click').on 'click', (e) ->
            $el = $(e.currentTarget).parent()
            if $el.hasClass("flip")
              $el.removeClass("flip")
              item.scale_x = 1
            else
              $el.addClass("flip")
              item.scale_x = -1

          element.find('.ffe-item__flop').off('click').on 'click', (e) ->
            $el = $(e.currentTarget).parent()
            if $el.hasClass("flop")
              $el.removeClass("flop")
              item.scale_y = 1
            else
              $el.addClass("flop")
              item.scale_y = -1

          items.select(key)
          dir.scope.$apply()

        else
          position_x = ui.offset.left - $(this).offset().left
          position_y = ui.offset.top - $(this).offset().top

  # deselect item on canvas click, seems a little bit dirty, but works
  $(".ffe-editor").off('mousedown').on 'mousedown', (e) ->
    e.stopPropagation()
    if $(e.target).hasClass('ffe-editor__canvas') || $(e.target).hasClass('ffe-editor__wrapper')
      $('.ffe-item').removeClass('active')
      Item.selected = undefined
      dir.scope.$apply()

  dir
]