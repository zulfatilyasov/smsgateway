import React from 'react';
import {Paper, TextField, RaisedButton, FlatButton} from 'material-ui';
import userActions  from '../../actions/UserActions.es6';
import Spinner from '../spinner/spinner.jsx'
import style from './login.styl'

function validateEmail(email) {
    var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
    return re.test(email);
}

var Login = React.createClass({

    getInitialState: function () {
        return {
            email: '',
            password: '',
            emailValid: false,
            passwordValid: false,
            emailErrorText: '',
            passwordErrorText: ''
        };
    },

    _handleEmailBlur: function (e) {
        var errorMsg = '';
        if (!e.target.value) {
            errorMsg = 'email is required';
        } else if (validateEmail(e.target.value) === false) {
            errorMsg = 'email is not valid';
        }
        var isValid = errorMsg === '';

        this.setState({emailErrorText: errorMsg, emailValid: isValid});
    },

    _handlePasswordBlur: function (e) {
        var errorMsg = e.target.value ? '' : 'password required';
        var isValid = errorMsg === '';

        this.setState({passwordErrorText: errorMsg, passwordValid: isValid});
    },

    _handleEmailChange: function (e) {
        this.setState({email: e.target.value});
    },

    _handlePasswordChange: function (e) {
        var isValid = e.target.value.length;
        this.setState({password: e.target.value, passwordValid: isValid});
    },

    _handleLogin: function (e) {
        e.preventDefault();

        var creds = {
            email: this.state.email,
            password: this.state.password
        };

        if (this.state.emailValid && this.state.passwordValid) {
            userActions.login(creds);
        }
    },

    render: function () {
        return (
            <div className="login-wrap">
                <h1 className="login-header">SMS Gateway</h1>

                <form className="login-form" onSubmit={this._handleLogin}>
                    <Paper zDepth={1}>
                        <div className="padded">
                            <Spinner/>

                            <TextField
                                hintText="Email"
                                errorText={this.state.emailErrorText}
                                floatingLabelText="Enter your email"
                                onChange={this._handleEmailChange}
                                onBlur={this._handleEmailBlur}/>

                            <TextField
                                hintText="Password"
                                errorText={this.state.passwordErrorText}
                                floatingLabelText="Enter your password"
                                type="password"
                                onChange={this._handlePasswordChange}
                                onBlur={this._handlePasswordBlur}/>

                            <RaisedButton
                                primary={true}
                                disabled={!this.state.emailValid || !this.state.passwordValid}
                                onClick={this._handleLogin}
                                className="login-button"
                                label="Login"/>

                            <div className="secondary-buttons">
                                <FlatButton secondary={true} className="register-button" label="Register"/>
                                <FlatButton secondary={true} className="forgot-button" label="Forgot the password?"/>
                            </div>

                        </div>
                    </Paper>
                </form>
            </div>
        );
    }
});

module.exports = Login;