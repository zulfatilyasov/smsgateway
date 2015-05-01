React = require 'react'
AppDispatcher = require '../AppDispatcher.coffee'
RouteConstants = require '../constants/RouterConstants.js'
userStore = require '../stores/UserStore.coffee'
router = require '../router.coffee'

RouteActions =
  checkPermissions: (state)->
    if state.path isnt '/login'
      if not userStore.isAuthenticated()
        router.replaceWith('/login')

    # AppDispatcher.handleViewAction
    #     actionType: RouteConstants.ROUTE_CHANGED
    #     state: state

module.exports=RouteActions


