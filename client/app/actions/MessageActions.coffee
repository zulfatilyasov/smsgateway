AppDispatcher = require '../AppDispatcher.coffee'
MessageConstants = require '../constants/MessageConstants.js'
userActions = require './UserActions.coffee'
apiClient = require '../services/apiclient.coffee'
config = require '../config.coffee'

messagesLoaded = false
MessageActions = 
    getUserMessages: (userId) ->
        if not userId
            userActions.logout()
            return 

        if messagesLoaded
            return

        console.log 'called get user messages'
        apiClient.getUserMessages userId
            .then (resp) ->
                    messages = resp.body
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.RECEIVED_ALL_MESSAGES
                        messages: messages
                    messagesLoaded = true
                , (err) ->
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.GET_ALL_MESSAGES_FAIL
                        messages: messages

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
