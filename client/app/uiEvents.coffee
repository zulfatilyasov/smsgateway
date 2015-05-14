_ = require 'lodash'

EventEmitter = require('events').EventEmitter
assign = require('object-assign')
CHANGE_EVENT = 'change-header'
CLICK_CREATE_MESSAGE_EVENT = 'create-message'
SHOW_DIALOG = 'show-dialog'
CLOSE_DIALOG = 'close-dialog'

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

    showDialog:(dialogContent) ->
        @emit SHOW_DIALOG, dialogContent

    addShowDialogListener:(callback) ->
        @on SHOW_DIALOG, callback 

    removeShowDialogListener:(callback)->
        @removeListener SHOW_DIALOG, callback

    closeDialog: ->
        @emit CLOSE_DIALOG

    addCloseDialogListener:(callback) ->
        @on CLOSE_DIALOG, callback 

    removeCloseDialogListener:(callback)->
        @removeListener CLOSE_DIALOG, callback
        
assign(HeaderEvents.prototype, EventEmitter.prototype)

module.exports = new HeaderEvents();