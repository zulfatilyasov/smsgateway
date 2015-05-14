_ = require 'lodash'

AppDispatcher = require('../AppDispatcher.coffee')
EventEmitter = require('events').EventEmitter
assign = require('object-assign')
CHANGE_EVENT = 'change'


class BaseStore 
    constructor: (actions) ->
        return unless _.isObject(actions) 

        AppDispatcher.register (payload) ->
            action = payload.action

            if actions[action.actionType]
                actions[action.actionType](action)
                
            return true

    emitChange: ->
        @emit(CHANGE_EVENT)

    addChangeListener: (callback) ->
        @on(CHANGE_EVENT, callback)

    removeChangeListener: (callback) ->
        @removeListener CHANGE_EVENT, callback

assign(BaseStore.prototype, EventEmitter.prototype)

module.exports = BaseStore;
