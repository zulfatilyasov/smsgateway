Dispatcher = require 'flux/lib/Dispatcher'
assign = require 'object-assign'

AppDispatcher = assign new Dispatcher(),
  handleViewAction: (action) ->
    console.log action.actionType
    if action.actionType
      @dispatch
        source: 'VIEW_ACTION'
        action: action

  handleServerAction: (action) ->
    console.log action.actionType
    if action.actionType
      @dispatch
        source: 'SERVER_ACTION'
        action: action

module.exports = AppDispatcher;
