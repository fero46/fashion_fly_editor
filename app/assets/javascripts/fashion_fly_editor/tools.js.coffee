String::startsWith ?= (s) -> @[...s.length] is s
String::endsWith   ?= (s) -> s is '' or @[-s.length..] is s

# GLOBAL TOOLS
window.endpoint_to_url = (endpoint) ->
  if endpoint.startsWith('http')
    return endpoint
  else
    document.URL.replace("combine", "")+endpoint