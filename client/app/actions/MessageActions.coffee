AppDispatcher = require '../AppDispatcher.coffee'
MessageConstants = require '../constants/MessageConstants.js'
ioConstants = require '../../../common/constants/ioConstants.coffee'
apiClient = require '../services/apiclient.coffee'
config = require '../config.coffee'
socketIO = require '../services/socket.coffee'

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

    getUserMessages: (userId, section) ->
        if @messagesLoaded
            console.log 'masseges already loaded'
            return

        console.log 'called get user messages'
        apiClient.getUserMessages userId, section
            .then (resp) ->
                    messages = resp.body
                    setTimeout ->
                        AppDispatcher.handleViewAction
                            actionType: MessageConstants.RECEIVED_ALL_MESSAGES
                            messages: messages
                        @messagesLoaded = true
                    , 100
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

    send: (message) ->
        apiClient.sendMessage message
            .then (resp) ->
                savedMessage = resp.body
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.SEND_SUCCESS
                    message: savedMessage
            , (err) ->
                AppDispatcher.handleViewAction
                    actionType: MessageConstants.SEND_FAIL
                    error: err
                    message:message

        AppDispatcher.handleViewAction
            actionType: MessageConstants.SEND
            message: message

module.exports = MessageActions;
