MessagesPage = require('./messagesPageObject.coffee')
describe 'Messages', ->
  messagesPage = null
  beforeEach ->
    browser.ignoreSynchronization = true
    messagesPage = new MessagesPage
    messagesPage.get()
    browser.sleep 1000
    
  describe 'Name of the group', ->
    it 'should send message', ->
      messagesPage.openNewMessageForm()
      browser.driver.wait protractor.until.elementIsVisible(element(By.css('.phoneInput input'))), 5000
      address = '+79274608371'
      body = 'hello'
      messagesPage.setAddress(address).setBody(body).submitNewMessageForm()
      browser.driver.wait protractor.until.elementIsVisible(messagesPage.firstMessage.address), 5000
      expect(messagesPage.firstMessage.address.getText()).toEqual address
      expect(messagesPage.firstMessage.body.getText()).toEqual body
      browser.sleep 500
      
    it 'should remove message', ->
      messagesPage.firstMessage.menuControl.click()
      browser.driver.wait protractor.until.elementIsVisible(messagesPage.firstMessage.deleteButton), 10000
      messagesPage.firstMessage.deleteButton.click()
      browser.sleep 500
      browser.switchTo().alert().accept()
      browser.sleep 500