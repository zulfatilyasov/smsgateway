validators =
  isValidPhone: (phone) ->
    number = phone.replace /[^0-9]/g, ''
    if number.length < 8 or number.length > 12 then false else true

  isValidEmail:(email)->
    re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
    re.test email

  isValidDate:(date)->
    if date.length < 6
      return false
    d = new Date(date)
    return not isNaN(d.valueOf())

module.exports = validators
