React = require('react')
LoginForm  = require('./login.cjsx')
Overlay = require('../overlay/overlay.jsx')
Table = require('../table/table.jsx')
userStore = require('../../stores/UserStore.coffee')
router = require('../../router.coffee')

class LoginPage extends React.Component 
    constructor: (props, context) ->
      super(props)

    componentDidMount: ->
      userStore.addChangeListener @onChange

    componentWillUnmount: ->
      userStore.removeChangeListener @onChange

    onChange: ->
      if userStore.isAuthenticated()
        router.transitionTo('/')

    render: -> 
        <Overlay>
            <LoginForm>
            </LoginForm>
        </Overlay>

module.exports = LoginPage
