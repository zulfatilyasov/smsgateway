ui = 
  getScrollHeight : ->
      window.pageYOffset or document.documentElement.scrollTop

  getDocHeight : ->
      body = document.body
      html = document.documentElement
      Math.max(body.scrollHeight, body.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight)

  bottomDistance: ->
    @getDocHeight() - @getScrollHeight()

module.exports = ui
