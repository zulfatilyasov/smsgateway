AppDispatcher = require '../AppDispatcher.coffee'
MessageConstants = require '../constants/MessageConstants.js'
ContactConstants = require '../constants/ContactConstants.coffee'
userConstants = require '../constants/UserConstants.js'
ioConstants = require '../../../common/constants/ioConstants.coffee'
apiClient = require '../services/apiclient.coffee'
config = require '../config.coffee'
socketIO = require '../services/socket.coffee'
_ = require 'lodash'

MessageActions = 
    messagesLoaded : false

    clean: ->
        @messagesLoaded = false
        AppDispatcher.handleViewAction
            actionType: MessageConstants.CLEAN

    resend:(msg) ->
        AppDispatcher.handleViewAction
            actionType: MessageConstants.RESEND
            message:msg

    clearResend:->
        AppDispatcher.handleViewAction
            actionType: MessageConstants.CLEARRESEND

    selectAllItems: (value) ->
        AppDispatcher.handleViewAction
            actionType: MessageConstants.SELECT_ALL
            value: value

    cancelMessages: (messageIds, userId) ->
        apiClient.cancelMessages messageIds, userId
            .then ->
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.MESSAGES_CANCEL_SUCCESS
                    messageIds: messageIds
                    
            , (error) ->
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.MESSAGES_CANCEL_FAILED
                    error: error

    deleteMany: (messageIds) ->
        apiClient.deleteMany messageIds
            .then ->
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.DELETED_MESSAGES
                    messageIds: messageIds
                    
            , (error) ->
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.DELETE_MESSAGES_FAILED
                    error: error

    resend: (messageIds) ->
        apiClient.resend messageIds
            .then (resp) ->
                messages = resp.body.messages
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.RESEND_MESSAGES_SUCCESS
                    messages: messages
                    
            , (error) ->
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.RESEND_MESSAGES_FAILED
                    error: error

        AppDispatcher.handleViewAction
            actionType: MessageConstants.RESEND_MESSAGES
            messageIds: messageIds

    selectSingle: (messageId) ->
        AppDispatcher.handleViewAction
            actionType: MessageConstants.SELECT
            messageId: messageId

    updateUsersMessageStar: (userId, messageId, starred)->
        apiClient.updateUsersMessageStar(userId, messageId, starred)
            .then (resp) ->
                    message = resp.body
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.MESSAGE_STAR_UPDATED
                        message: message

                , (err) ->
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.MESSAGE_STAR_FAILED
                        error: err

        AppDispatcher.handleViewAction
            actionType: MessageConstants.MESSAGE_STAR
            starred: starred

    deleteMessage: (userId, messageId) ->
        apiClient.deleteMessage(userId, messageId)
            .then (resp) ->
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.MESSAGE_DELETED
                    messageId: messageId

    searchUserMessages: (userId, query) ->
        apiClient.searchUserMessages(userId, query) 
            .then (resp) ->
                    messages = resp.body
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.RECEIVED_SEARCHED_MESSAGES
                        messages: messages

                , (err) ->
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.GET_SEARCHED_MESSAGES_FAIL
                        error: err

        AppDispatcher.handleViewAction
            actionType: MessageConstants.SEARCH_MESSAGES

    getUserMessages: (userId, section, skip=0, limit=50) ->
        if @messagesLoaded
            console.log 'masseges already loaded'
            return

        apiClient.getUserMessages userId, section, skip, limit
            .then (resp) ->
                    messages = resp.body
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.RECEIVED_ALL_MESSAGES
                        messages: messages
                        section:section
                        skiped:skip
                    @messagesLoaded = true
                , (err) ->
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.GET_ALL_MESSAGES_FAIL
                        error: err

        AppDispatcher.handleViewAction
            actionType: MessageConstants.GET_MESSAGES

    startReceiving: ->
        socket = socketIO.getSocket()
        socket.on ioConstants.SEND_MESSAGE, (message) ->
            AppDispatcher.handleServerAction
                actionType: MessageConstants.MESSAGE_RECEIVED
                message: message

        socket.on ioConstants.UPDATE_MESSAGE, (message) ->
            notifyUpdate = ->
                AppDispatcher.handleServerAction
                    actionType: MessageConstants.UPDATE_MESSAGE
                    message: message

            setTimeout notifyUpdate, 1000

    sendToMultipleContacts:(message, contacts, groups)->
        apiClient.sendToMultipleContacts(message, contacts, groups)
             .then (resp) ->
                savedMessages = resp.body.messages
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.SEND_MULTIPLE_SUCCESS
                    messages: savedMessages

                if savedMessages?.length
                    messageBody = savedMessages[0].body
                    AppDispatcher.handleViewAction
                        actionType: userConstants.SHOW_SNACK
                        message: 'Created message ' + messageBody

            , (err) ->
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.SEND_MULTIPLE_FAIL
                    error: err
                    message:message

        AppDispatcher.handleViewAction
            actionType: MessageConstants.SEND

module.exports = MessageActions;
