angular.module("ffe").directive 'translate', ->
  link: (scope, element, attrs) ->
    $(element).text(window.translate(attrs.translate))