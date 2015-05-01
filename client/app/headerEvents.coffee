_ = require 'lodash'

EventEmitter = require('events').EventEmitter
assign = require('object-assign')
CHANGE_EVENT = 'change'

class HeaderEvents 
    constructor: ->

    emitChange:(header) ->
        @emit(CHANGE_EVENT, header)

    addChangeListener: (callback) ->
        @on(CHANGE_EVENT, callback)

    removeChangeListener: (callback) ->
        @removeListener CHANGE_EVENT, callback

assign(HeaderEvents.prototype, EventEmitter.prototype)

module.exports = new HeaderEvents();