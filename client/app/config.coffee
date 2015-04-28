devHost = 'http://192.168.0.2:3200'

config = 
  host: ''

if process.env.NODE_ENV == "development"
  config.host = devHost


module.exports = config