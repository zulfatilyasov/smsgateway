# jest.dontMock '../login.cjsx'
# jest.dontMock 'material-ui'
# jest.dontMock 'react'

# describe 'Login form',  ->
#   it 'should render two input fields', ->
#     React = require 'react/addons'
#     Login = require '../login.cjsx'
#     container = require '../../settings/container.cjsx'
#     mui = require('material-ui')
#     TestUtils = React.addons.TestUtils
#     login = TestUtils.renderIntoDocument(<Login/>)
#     header = TestUtils.findRenderedDOMComponentWithClass(login, 'login-header')

#     expect header.getDOMNode().textContent
#     .toEqual 'SMS Gateway'