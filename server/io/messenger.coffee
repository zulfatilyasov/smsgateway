redis = require 'redis'
db = redis.createClient() 
ioconstants = require './ioConstants.coffee'

class Messenger
  initialize: (app) ->
    @app = app
    @io = app.io
    @io.use (socket, next) =>
      if socket.request._query?.registerToken
        accessToken = socket.request._query.registerToken
        @registerClient(accessToken, socket.id, next)

    @io.on 'connection', (socket) ->
      console.log 'client connected'

  on: (messageId, callback) ->
    @io.on messageId, callback

  registerClient: (accessToken, clientId, next) ->
    @app.models.AccessToken.findById accessToken, (err, token) ->
      if err
        next(err)
      else
        db.hset token.userId, 'mobile', clientId, ->
          console.log "registered client #{clientId} userId #{token.userId}"
          next()

  sendMessageToUserMobile: (userId, message) ->
    @getMobileClientIdForUser userId, (err, clientId) =>
      @sendMessageToClient clientId, message

  sendMessageToUserWeb: (userId, message) ->
    @getWebClientIdForUser userId, (err, clientId) =>
      @sendMessageToClient clientId, message

  sendMessageToClient: (clientId, message) ->
    @io.to(clientId).emit ioconstants.SEND_MESSAGE, message

  getMobileClientIdForUser: (userId, callback) ->
    db.hget userId, 'mobile', callback

  getWebClientIdForUser: (userId, callback) ->
    db.hget userId, 'web', callback

  updateMessageStatus: (userId, messageId, status) ->
    console.log 'update message status'

module.exports = new Messenger()
  
