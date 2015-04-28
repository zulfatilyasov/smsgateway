prod = 'http://smsgateway.zulfat.net'
dev = 'http://192.168.0.2:3200'
host = ''

if process.env.NODE_ENV == "development"
  host = dev
else
  host = prod

config = 
  host: host

module.exports = config