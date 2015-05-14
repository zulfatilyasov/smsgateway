loopback = require 'loopback'
_ = require 'lodash'

class MessageHelpers
  constructor: (MessageModel) ->
    @Message = MessageModel

  saveReceivedMessage: (request) ->
    console.log 'not implemented'

  updateMessageStatus: (request) ->
    console.log 'not implemented'

  authenticate: (cb) ->
    ctx = loopback.getCurrentContext();
    token = ctx && ctx.get('accessToken');
    unless token and token.userId
      err = new Error('not authorized')
      err.statusCode = 401
      err.code = 'LOGIN_FAILED'
      cb err
    else
      cb null, token

  getUserMessagesByIds: (ids, cb) ->
    @authenticate (authError, token) =>
      if authError
        cb authError
      else
        query =
          where:
            id:inq:ids
            userId: token.userId
        @Message.find query, cb

  resendMessages:(messages, cb) ->
    messages = _.map messages, (m)->
      m.status = 'queued'
      m.id = null
      return m

    console.log messages
    @Message.create messages, (err, data)->
      if err then cb err else cb null, data

  setCancelled: (messageIds, cb) ->
    @authenticate (authError, token) =>
      if authError
        cb authError
      else
        query = 
          userId:token.userId
          id:inq:messageIds
          status:'queued'
        @Message.updateAll query, status:'cancelled', cb

  getUserMessagesByStatus: (userId, status, cb) ->
    query =
      where:
        status:status
        userId:userId
    console.log query
    @Message.find query, cb


module.exports = MessageHelpers