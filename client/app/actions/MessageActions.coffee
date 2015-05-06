AppDispatcher = require '../AppDispatcher.coffee'
MessageConstants = require '../constants/MessageConstants.js'
apiClient = require '../services/apiclient.coffee'
config = require '../config.coffee'

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

    updateMessageStar: (messageId, starred)->
        apiClient.updateMessageStar(messageId, starred)
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
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.RECEIVED_ALL_MESSAGES
                        messages: messages
                    @messagesLoaded = true
                , (err) ->
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.GET_ALL_MESSAGES_FAIL
                        error: err

        AppDispatcher.handleViewAction
            actionType: MessageConstants.GET_MESSAGES

    startReceiving: ->
        token = localStorage.getItem 'sg-token'
        query = "registerToken=#{token}&origin=web";
        socket = io.connect config.host, query:query
        socket.on 'send-message', (message) ->
            AppDispatcher.handleServerAction
                actionType: MessageConstants.MESSAGE_RECEIVED
                message: message

    send: (message) ->
        console.log 'called send message'
        apiClient.sendMessage message
            .then (resp) ->
                setTimeout ->
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.SEND_SUCCESS
                        message: message
                , 1000

            , (err) ->
                setTimeout ->
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.SEND_FAIL
                        error: err
                        message:message
                , 1000

        AppDispatcher.handleViewAction
            actionType: MessageConstants.SEND
            message: message

module.exports = MessageActions;
