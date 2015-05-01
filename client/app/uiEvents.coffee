_ = require 'lodash'

EventEmitter = require('events').EventEmitter
assign = require('object-assign')
CHANGE_EVENT = 'change-header'
CLICK_CREATE_MESSAGE_EVENT = 'create-message'

class HeaderEvents 
    constructor: ->

    emitChange:(header) ->
        @emit(CHANGE_EVENT, header)

    addChangeListener: (callback) ->
        @on(CHANGE_EVENT, callback)

    removeChangeListener: (callback) ->
        @removeListener CHANGE_EVENT, callback

    emitCreateMessageClick:() ->
        @emit(CLICK_CREATE_MESSAGE_EVENT)

    addCreateMessageClickListener: (callback) ->
        @on(CLICK_CREATE_MESSAGE_EVENT, callback)

    removeCreateMessageClickListener: (callback) ->
        @removeListener CLICK_CREATE_MESSAGE_EVENT, callback
        
assign(HeaderEvents.prototype, EventEmitter.prototype)

module.exports = new HeaderEvents();