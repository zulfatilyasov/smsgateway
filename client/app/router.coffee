router = {}

module.exports =
  makePath:(to, params, query) -> 
    router.makePath(to, params, query)

  makeHref:(to, params, query) ->
    router.makeHref(to, params, query)

  transitionTo:(to, params, query) ->
    router.transitionTo(to, params, query)

  replaceWith:(to, params, query) ->
    router.replaceWith(to, params, query)

  getPathname:->
    router.getCurrentPathname()
    
  goBack: ->
    router.goBack()

  run: (render)->
    router.run(render)

routes = require('./app-routes.jsx')
Router = require('react-router')

router = Router.create({
  routes: routes,
});
