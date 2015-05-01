BaseStore = require './BaseStore.coffee';
routeConstants = require '../constants/RouterConstants.js';

_state = null

class RouteStore extends BaseStore
    constructor:(actions) ->
        super(actions)

    currentState: ->
        _state

actions = {}

actions[routeConstants.ROUTE_CHANGED] = (action) ->
    _state = action.state
    storeInstance.emitChange()

storeInstance = new RouteStore(actions)

module.exports = storeInstance
