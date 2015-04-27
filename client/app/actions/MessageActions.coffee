AppDispatcher = require '../AppDispatcher.coffee'
MessageConstants = require '../constants/MessageConstants.js'
apiClient = require '../services/apiclient.coffee'
config = require '../config.coffee'

MessageActions = 
    getUserMessages: (userId) ->
        apiClient.getUserMessages userId
            .then (resp) ->
                    messages = resp.body
                    AppDispatcher.handleViewAction
                        actionType: MessageConstants.RECEIVED_ALL_MESSAGES
                        messages: messages
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
