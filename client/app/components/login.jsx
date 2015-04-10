var React = require('react');
var mui = require('material-ui');
var Paper = mui.Paper;
var TextField = mui.TextField;
var RaisedButton = mui.RaisedButton;
var FlatButton = mui.FlatButton;
var userActions = require('../actions/UserActions.es6');
var style = {padding: 25};
var Login = React.createClass({

    getInitialState: function () {
        return {
            emailErrorText: '',
            passwordErrorText: ''
        };
    },

    _handleEmailChange: function (e) {

    },

    _handlePasswordChange: function (e) {

    },

    _handleLogin: function() {
        console.log('handle login');
        userActions.login();
    },

    render: function () {
        return (
            <div className="login-wrap">
                <h1 className="login-header">SMS Gateway</h1>
                <div className="login-form ">
                    <Paper zDepth={1}>
                        <div className="padded">
                            <TextField
                                hintText="Email"
                                errorText={this.state.emailErrorText}
                                floatingLabelText="Enter your email"
                                onChange={this._handleEmailChange}/>
                            <TextField
                                hintText="Password"
                                errorText={this.state.emailErrorText}
                                floatingLabelText="Enter your password"
                                type="password"
                                onChange={this._handlePasswordChange}/>

                            <RaisedButton primary={true} onClick={this._handleLogin} className="login-button" label="Login"/>
                            <div className="secondary-buttons">
                                <FlatButton secondary={true} className="register-button" label="Register"/>
                                <FlatButton secondary={true} className="forgot-button" label="Forgot the password?"/>
                            </div>

                        </div>
                    </Paper>
                </div>
            </div>
        );
    }
});

module.exports = Login;