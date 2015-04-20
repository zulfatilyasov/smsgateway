Dispatcher = require 'flux/lib/Dispatcher'
assign = require 'object-assign'

AppDispatcher = assign new Dispatcher(),
    handleViewAction: (action) ->
        @dispatch
            source: 'VIEW_ACTION'
            action: action

    handleServerAction: (action) ->
        @dispatch
            source: 'SERVER_ACTION'
            action: action

module.exports = AppDispatcher;
