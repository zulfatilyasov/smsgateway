config = require '../config.coffee'
class SocketIO
  _connect: ->
    token = localStorage.getItem 'sg-token'
    query = "accessToken=#{token}&origin=web";
    @socket = io.connect config.host, query:query
    return @socket

  getSocket: ->
    if not @socket
      @socket = @_connect()
    return @socket

module.exports = new SocketIO()