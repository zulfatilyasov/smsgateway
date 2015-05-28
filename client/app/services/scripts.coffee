loadScript = require 'load-script'

scripts = 
  loadJs:(url,cb) ->
    loadScript(url, cb)

  loadCss:(id, url) ->
    cssId = id
    if !document.getElementById(cssId)
        head  = document.getElementsByTagName('head')[0]
        link  = document.createElement('link')
        link.id   = cssId
        link.rel  = 'stylesheet'
        link.type = 'text/css'
        link.href = url
        link.media = 'all'
        head.appendChild(link)
  papaParse:'/client/build/static/js/papaparse.min.js'
  handsOnTableJs:'https://cdnjs.cloudflare.com/ajax/libs/handsontable/0.14.1/handsontable.full.min.js'
  handsOnTableCss:'https://cdnjs.cloudflare.com/ajax/libs/handsontable/0.14.1/handsontable.full.min.css'

module.exports = scripts
