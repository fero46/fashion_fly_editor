'use strict';

app = angular.module('ffe', ['ngResource', 'ngDialog', 'ngSanitize', 'ffe.controllers'])

app.config ($httpProvider) ->
  #authToken = $("meta[name=\"csrf-token\"]").attr("content")
  #$httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
  $httpProvider.defaults.headers.common["Accept"] = 'application/json'
