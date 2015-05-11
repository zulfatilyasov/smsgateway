class MessagesPage
  constructor: ->
    @header = element(By.css('.section-header h2'))
    @createMessage = element(By.css('.create-message button'))
    @addressInput = element By.css('.phoneInput input')
    @bodyInput = element By.css('.msgInput .mui-text-field-textarea')
    @sendButton = element By.css('.sendButton')
    @firstMessage = 
      address: element By.css('.message-item:first-child .message-address')
      body: element By.css('.message-item:first-child .body')
      menuControl: element By.css('.message-item:first-child .mui-menu-control')
      deleteButton: element By.css('.message-item:first-child .menu-delete')
      toggleMenu: ->
        @menuControl.click()

  get: ->
    browser.get('http://localhost:3100/#/messages/all')
    return @

  openNewMessageForm: ->
    @createMessage.click()
    return @

  setAddress: (text) ->
    @addressInput.sendKeys(text)
    return @

  clearAddress: ->
    @addressInput.clear()
    return @

  setBody: (text) ->
    @bodyInput.sendKeys(text)
    return @

  clearBody: ->
    @bodyInput.clear()
    return @

  submitNewMessageForm: () ->
    @sendButton.click()
    return @

module.exports = MessagesPage