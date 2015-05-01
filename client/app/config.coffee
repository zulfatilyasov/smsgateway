devHost = 'http://localhost:3200'

config = 
  host: ''

if process.env.NODE_ENV == "development"
  config.host = devHost


module.exports = config