request = require 'superagent-promise'
config = require '../config.coffee'
_ = require 'lodash'

class ApiClient 
    constructor: (host = '', baseUrl = '') ->
        @accessToken = ''
        @prefix = host + baseUrl
        @_pendingRequests = {}

    _getToken: ->
        localStorage.getItem 'sg-token'

    _getMessagesFilter: (section = 'all', skip, limit) ->
        filter = '?filter[order]=id%20DESC&filter[limit]=' + limit + '&filter[skip]=' + skip
        if section is 'outcoming'
           filter += '&filter[where][outcoming]=true'
        if section is 'incoming'
           filter += '&filter[where][incoming]=true'
        if section is 'starred'
           filter += '&filter[where][starred]=true'
        if section is 'sent'
           filter += '&filter[where][status]=sent'
        if section is 'failed'
           filter += '&filter[where][status]=failed'
        if section is 'queued'
           filter += '&filter[where][status]=queued'
        if section is 'cancelled'
           filter += '&filter[where][status]=cancelled'
        return filter


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
            
    getUserVariables:(userId) ->
        request
            .get @prefix + '/users/' + userId + '/contactVariables'
            .set 'Authorization',  @_getToken()
            .end()

    deleteMany: (messageIds) ->
        request
            .post @prefix + '/messages/delete_many'
            .send ids:messageIds
            .set 'Authorization', @_getToken()
            .end()

    cancelMessages: (messageIds, userId) ->
        messageIds = JSON.stringify(messageIds)
        request
            .post @prefix + '/messages/cancel'
            .send
                ids:messageIds
            .set 'Authorization', @_getToken()
            .end()

    deleteContacts: (contactIds)->
        request
            .post @prefix + '/contacts/deleteMany'
            .send ids:contactIds
            .set 'Authorization', @_getToken()
            .end()

    sendToMultipleContacts:(message, contacts, groups)->
        request
            .post @prefix + '/messages/send'
            .send
                message:message
                contacts:contacts
                groups:groups
            .set 'Authorization', @_getToken()
            .end()

    resend: (messageIds) ->
        request
            .post @prefix + '/messages/resend'
            .send ids:messageIds
            .set 'Authorization', @_getToken()
            .end()

    updateMultipleContacts: (contacts) ->
        request
            .post @prefix + '/contacts/updateMany'
            .send contacts:contacts
            .set 'Authorization', @_getToken()
            .end()

    createContactVariable: (variable)->
        request
            .post @prefix + '/contactVariables'
            .send variable
            .set 'Authorization', @_getToken()
            .end()
            
    updateMultipleGroups: (groups) ->
        request
            .post @prefix + '/groups/updateMany'
            .send groups:groups
            .set 'Authorization', @_getToken()
            .end()

    register: (registrationData) ->
        request
            .post @prefix + '/users'
            .send registrationData
            .end()

    getUserMessages: (userId, section, skip, limit) ->
        filter = @_getMessagesFilter(section, skip, limit)
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

    getUserGroups: (userId) ->
        request
            .get @prefix + '/users/' + userId + '/groups'
            .set 'Authorization', @_getToken()
            .end()

    deleteGroup: (userId, groupId) ->
        request
            .del "#{@prefix}/users/#{userId}/groups/#{groupId}" 
            .set 'Authorization', @_getToken()
            .end()

    createUserGroups:(userId, groups) ->
        request
            .post @prefix + '/users/' + userId + '/groups'
            .send groups
            .set 'Authorization', @_getToken()
            .end()

    saveContact:(userId, contact) ->
        if not _.isArray(contact) and contact.id
            request
                .put @prefix + '/users/' + userId + '/contacts/' + contact.id
                .send contact
                .set 'Authorization', @_getToken()
                .end()
        else
            request
                .post @prefix + '/users/' + userId + '/contacts'
                .send contact
                .set 'Authorization', @_getToken()
                .end()

    getAddressList:()->
        request
            .get @prefix + '/contacts/addresslist'
            .set 'Authorization', @_getToken()
            .end()

    getUserContacts: (userId, groupId, skip, limit) ->
        if groupId
            request
                .get @prefix + '/groups/' + groupId + '/contacts?limit=' + limit + '&skip=' + skip
                .set 'Authorization', @_getToken()
                .end()
        else
            request
                .get @prefix + '/users/' + userId + '/contacts?filter[order]=id%20DESC&filter[limit]=' + limit + '&filter[skip]=' + skip
                .set 'Authorization', @_getToken()
                .end()

module.exports = new ApiClient config.host, '/api'