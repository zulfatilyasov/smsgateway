React = require('react')
LoginForm  = require('./login.cjsx')
Overlay = require('../overlay/overlay.jsx')
Table = require('../table/table.jsx')

class LoginPage extends React.Component 
    constructor: (props) ->
        super(props)

    render: -> 
        <Overlay>
            <LoginForm>
            </LoginForm>
        </Overlay>

module.exports = LoginPage
