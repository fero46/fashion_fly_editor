angular.module("ffe").directive('dropdown', ['$timeout', ($timeout) ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    if scope.$last
      _scope = scope
      # somehow dropdown renders again on category change, so lets remove old
      # rendered dropdowns
      $('div.dropdown').remove();

      # reset filter
      $('body').on 'click', '.dropdown i', (e) =>
        $option = $(e.currentTarget).closest('div.dropdown').next('select').find('option:first-child')
        filter  = $option.data('filter')

        if filter?
          filter = filter.split('_')[1]
          text = $option.text()

          # reset filter, on second run, scope.$parent = nil, dont know why
          if scope.$parent?
            scope.$parent.resetFilter(filter)
          else
            scope.resetFilter(filter)
          # set text
          $(e.currentTarget).closest('.selected').text(text)
          # hide elem
          $(e.currentTarget).css(display: 'none')

      # init dropdown
      $timeout(->

        element.closest('select').dropdown(
          changed: (data) ->
            filter = element.data('filter')
            if filter == 'filter_color'
              # set background-color
              if data.style?
                element.closest('.dropdown').prev('.dropdown').find('.color-indicator').css('background-color', data.value)
            scope.updateFilters(data, filter)
        )
      )
  ])