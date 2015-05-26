_ = require 'lodash'

EventEmitter = require('events').EventEmitter
assign = require('object-assign')
CHANGE_EVENT = 'change-header'
CLICK_CREATE_MESSAGE_EVENT = 'create-message'
SHOW_DIALOG = 'show-dialog'
CLOSE_DIALOG = 'close-dialog'
SHOW_IMPORT_TOOLBAR = 'show-import-toolbar'
SHOW_CONTACTS_TOOLBAR = 'show-contacts-toolbar'

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

    showImportToolbar: ->
        @emit SHOW_IMPORT_TOOLBAR

    addShowImportToolbarListener:(callback) ->
        @on SHOW_IMPORT_TOOLBAR, callback 

    removeShowImportToolbarListener:(callback)->
        @removeListener SHOW_IMPORT_TOOLBAR, callback

    showContactsToolbar: ->
        @emit SHOW_CONTACTS_TOOLBAR

    addShowContactsToolbarListener:(callback) ->
        @on SHOW_CONTACTS_TOOLBAR, callback 

    removeShowContactsToolbarListener:(callback)->
        @removeListener SHOW_CONTACTS_TOOLBAR, callback
        
assign(HeaderEvents.prototype, EventEmitter.prototype)

module.exports = new HeaderEvents();