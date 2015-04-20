jest.dontMock '../settings.cjsx'
jest.dontMock '../container.cjsx'
jest.dontMock 'material-ui'
jest.dontMock 'react'

describe 'Settings',  ->
  it 'shoud render email and password inputs', ->
    React = require 'react/addons'
    Settings = require '../settings.cjsx'
    Container = require '../container.cjsx'
    mui = require('material-ui')
    TestUtils = React.addons.TestUtils
    set = TestUtils.renderIntoDocument(<Settings/>)
    header = TestUtils.findRenderedDOMComponentWithClass(set, 'header')

    expect header.getDOMNode().textContent
    .toEqual 'Settings'