request = require 'superagent-promise'
config = require '../config.coffee'

class ApiClient 
    constructor: (host = '', baseUrl = '') ->
        @accessToken = ''
        @prefix = host + baseUrl
        @_pendingRequests = {}

    _getToken: ->
        localStorage.getItem 'sg-token'

    _getMessagesFilter: (section = 'all') ->
        if section is 'all'
            return ''
        if section is 'outcoming'
            return '?filter[where][outcoming]=true'
        if section is 'incoming'
            return '?filter[where][incoming]=true'
        if section is 'starred'
            return '?filter[where][starred]=true'
        if section is 'sent'
            return '?filter[where][status]=sent'
        if section is 'failed'
            return '?filter[where][status]=failed'
        if section is 'queued'
            return '?filter[where][status]=queued'
        if section is 'cancelled'
            return '?filter[where][status]=cancelled'

    _abortRequest: (key) ->
        if @_pendingRequests[key]
            @_pendingRequests[key]._callback = ->
            @_pendingRequests[key].abort()
            @_pendingRequests[key] = null

    login: (email, password) ->
        request
            .post @prefix + '/users/login'
            .send 
                email: email
                password: password
            .end()
            
    deleteMany: (messageIds) ->
        request
            .post @prefix + '/messages/delete_many'
            .send ids:messageIds
            .set 'Authorization', @_getToken()
            .end()

    cancelMessages:(messageIds, userId) ->
        messageIds = JSON.stringify(messageIds)
        request
            .post @prefix + '/messages/cancel'
            .send
                ids:messageIds
            .set 'Authorization', @_getToken()
            .end()

    resend: (messageIds) ->
        request
            .post @prefix + '/messages/resend'
            .send ids:messageIds
            .set 'Authorization', @_getToken()
            .end()

    register: (registrationData) ->
        request
            .post @prefix + '/users'
            .send registrationData
            .end()

    getUserMessages: (userId, section) ->
        filter = @_getMessagesFilter(section)
        request
            .get "#{@prefix}/users/#{userId}/messages#{filter}"
            .set 'Authorization', @_getToken()
            .end()

    deleteMessage: (userId, messageId) ->
        request
            .del "#{@prefix}/users/#{userId}/messages/#{messageId}" 
            .set 'Authorization', @_getToken()
            .end()

    sendMessage: (message) ->
        request
            .post @prefix + '/messages'
            .send message
            .set 'Authorization', @_getToken()
            .end()
    
    requestResetPassword: (email) ->
        request
            .post @prefix + '/users/request_reset_password'
            .send email
            .end()

    updateUsersMessageStar: (userId, messageId, starred) ->
        data =
            starred: starred
        request
            .put @prefix + '/users/' + userId + '/messages/' + messageId
            .set 'Authorization', @_getToken()
            .send data
            .end()

    getUserDevice: ->
        request
            .get "#{@prefix}/users/devices"
            .set 'Authorization', @_getToken()
            .end()

    searchUserMessages: (userId, query) ->
        request
            .get "#{@prefix}/users/#{userId}/messages?filter={\"where\": {\"body\": {\"like\": \"#{query}\"}}}" 
            .set 'Authorization', @_getToken()
            .end()

    resetPassword: (accessToken, password, confirmation) ->
        requestData =
            accessToken: accessToken
            password: password
            confirmation: confirmation

        request
            .post @prefix + '/users/setPassword'
            .send requestData
            .set 'Authorization', accessToken
            .end()


module.exports = new ApiClient config.host, '/api'