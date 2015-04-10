var React = require('react');
var LoginForm = require('../components/login.jsx');
var Overlay = require('../components/overlay.jsx');

var LoginPage = React.createClass({
    render() {
        return (
            <Overlay>
                <LoginForm>
                </LoginForm>
            </Overlay>
        )
    }
});

module.exports = LoginPage;