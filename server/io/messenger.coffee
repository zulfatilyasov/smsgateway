redis = require 'redis'
db = null
if process.env.NODE_ENV == "docker"
  db = redis.createClient('6379', 'redis')
else
  db = redis.createClient()

ioConstants = require '../../common/constants/ioConstants.coffee'

class Messenger
  initialize: (app) ->
    @app = app
    @io = app.io
    @io.use (socket, next) =>
      handshakeData = socket.request._query
      console.log handshakeData
      if handshakeData?.accessToken
        @registerClient(handshakeData, socket, next)

    @io.on 'connection', (socket) =>
      console.log socket.data.origin + ' client connected'
      if socket.data.origin is 'mobile'
        @sendPhoneModelToWeb socket.data.userId, socket.data.device
        @app.models.Message.sendQueued(socket.data.userId)

      socket.on 'disconnect', =>
        console.log socket.data.origin + ' client disconnected'
        if socket.data.origin is 'mobile'
          db.hdel socket.data.userId, 'deviceModel', =>
            @notifyWebMobileDisconnected(socket.data.userId, socket.data.device)

  on: (messageId, callback) ->
    @io.on messageId, callback

  removeClientDevice: (clientId) ->

  findUserToken: (accessToken, next, cb) ->
    @app.models.AccessToken.findById accessToken, (err, token) ->
      if err
        next(err)
      if !token
        next(new Error('not authorized'))
      else
        cb(token)

  registerClient: (handshakeData, socket, next) ->
    @findUserToken handshakeData.accessToken, next, (token) ->
      socket.data = handshakeData
      socket.data.userId = token.userId
      db.hset token.userId, handshakeData.origin, socket.id, ->
        console.log "registered client #{socket.id} userId #{token.userId} from #{handshakeData.origin}"
        if handshakeData.origin is 'mobile'
          db.hset token.userId, 'deviceModel', handshakeData.device, ->
            next()
        else 
          next()

  sendPhoneModelToWeb: (userId, model) ->
    @getWebClientIdForUser userId, (err, clientId) =>
      return unless not err and clientId
      @emitMessageToClient clientId, ioConstants.PHONE_MODEL, model

  notifyWebMobileDisconnected:(userId, deviceModel) ->
    @getWebClientIdForUser userId, (err, clientId) =>
      return unless not err and clientId
      @emitMessageToClient clientId, ioConstants.PHONE_DISCONNECTED, deviceModel

  sendMessageToUserMobile: (userId, message) ->
    @getMobileClientIdForUser userId, (err, clientId) =>
      return unless not err and clientId
      @emitMessageToClient clientId, ioConstants.SEND_MESSAGE, message

  sendMessageToUserWeb: (userId, message) ->
    @getWebClientIdForUser userId, (err, clientId) =>
      return unless not err and clientId
      @emitMessageToClient clientId, ioConstants.SEND_MESSAGE, message

  updateUserMessageOnWeb: (userId, message) ->
    @getWebClientIdForUser userId, (err, clientId) =>
      return unless not err and clientId
      @emitMessageToClient clientId, ioConstants.UPDATE_MESSAGE, message

  getMobileClientIdForUser: (userId, callback) ->
    db.hget userId, 'mobile', callback

  getUserDevice: (userId, cb) ->
    console.log userId
    db.hget userId, 'deviceModel', (err, deviceModel) ->
      console.log err
      cb(err, deviceModel)

  getWebClientIdForUser: (userId, callback) ->
    db.hget userId, 'web', callback

  emitMessageToClient: (clientId, messageType, message) ->
    console.log 'socket.io emitted message ' + messageType + ' ' + message
    @io.to(clientId).emit messageType, message

module.exports = new Messenger()
  
