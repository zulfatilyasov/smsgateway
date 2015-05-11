class LoginPage
    constructor: ->
        @email = element(By.css('.email-input input'))
        @password = element(By.css('.password-input input'))
        @loginButton = element(By.css('.loginButton button'))
        # @errorMessage = element(By.id('.loginButton button'))
 
    get: ->
        browser.get('http://localhost:3100/#/login')
        return @
 
    getErrorMessage: ->
        return @errorMessage.getText()
 
    setEmail: (text) ->
        @email.sendKeys(text)
        return @
 
    clearEmail: ->
        @email.clear()
        return @
 
    setPassword: (text) ->
        @password.sendKeys(text)
        return @
 
    clearPassword: ->
        @password.clear()
        return @
 
    submit: ->
        @loginButton.click()
 
module.exports = LoginPage