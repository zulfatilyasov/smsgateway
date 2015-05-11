require('coffee-script/register')
LoginPage = require './loginPageObject.coffee'

describe 'Login', ->
  loginPage = null

  beforeEach ->
    browser.ignoreSynchronization = true
    loginPage = new LoginPage()
    loginPage.get()

  it 'should log in', ->
    loginPage
      .setEmail 'mail@zulfat.net'
      .setPassword 'qweqwe'
      .submit()

    browser.sleep(2000)
    expect(browser.driver.getCurrentUrl()).toContain  '/messages'
    
    
