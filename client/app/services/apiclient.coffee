request = require 'superagent-promise'
config = require '../config.coffee'

class ApiClient 
    constructor: (host = '', baseUrl = '') ->
        @accessToken = ''
        @prefix = host + baseUrl
        @_pendingRequests = {}

    _getToken: ->
        localStorage.getItem 'sg-token'

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

    register: (registrationData) ->
        request
            .post @prefix + '/users'
            .send registrationData
            .end()

    getUserMessages: (userId) ->
        request
            .get "#{@prefix}/users/#{userId}/messages"
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