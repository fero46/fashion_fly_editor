angular.module("ffe").directive 'draggable', ->
  restrict:'A'
  link: (scope, element, attrs) ->
    element.draggable
      helper: 'clone'