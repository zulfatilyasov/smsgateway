import React from 'react';
import {Paper, TextField, RaisedButton, FlatButton} from 'material-ui';
import userActions  from '../../actions/UserActions.es6';
import userStore from '../../stores/UserStore.es6'
import Spinner from '../spinner/spinner.jsx'
import style from './login.styl'

function validateEmail(email) {
    var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
    return re.test(email);
}

function getState () {
    return {
        inProgress:userStore.InProgress,
        hasError:userStore.AuthError.hasError,
        errorMessage:userStore.AuthError.message
    };
}

var Login = React.createClass({

    getInitialState: function () {
        return {
            email: '',
            password: '',
            emailValid: false,
            passwordValid: false,
            emailErrorText: '',
            passwordErrorText: '',
            inProgress: userStore.InProgress,
            error:''
        };
    },
    
    componentDidMount: function() {
        userStore.addChangeListener(this._onChange);
    },
    
    componentWillUnmount: function() {
        userStore.removeChangeListener(this._onChange);
    },
    
    _onChange: function() {
        this.setState(getState());
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
        this.email = e.target.value;
    },

    _handlePasswordChange: function (e) {
        this.password = e.target.value;

        var isValid = e.target.value.length;

        if(!this.state.passwordValid){
            this.setState({password: e.target.value, passwordValid: isValid});
        }
    },

    _handleLogin: function (e) {
        e.preventDefault();

        var creds = {
            email: this.email,
            password: this.password
        };

        if (this.state.emailValid && this.state.passwordValid) {
            userActions.login(creds);
        }
    },

    render: function () {
        var className = this.state.inProgress ? 'hide' : '';
        var loginButtonClass = 'login-button ' + className;

        var errorClasses = 'auth-error';
        errorClasses += this.state.hasError ? '' : ' hide';

        return (
            <div className="login-wrap">
                <h1 className="login-header">SMS Gateway</h1>

                <form className="login-form" onSubmit={this._handleLogin}>
                    <Paper zDepth={1}>
                        <div className="padded">

                            <TextField
                                hintText="Email"
                                errorText={this.state.emailErrorText}
                                floatingLabelText="Enter your email"
                                onChange={this._handleEmailChange}
                                ref="emailInput"
                                onBlur={this._handleEmailBlur}/>

                            <TextField
                                hintText="Password"
                                errorText={this.state.passwordErrorText}
                                floatingLabelText="Enter your password"
                                type="password"
                                onChange={this._handlePasswordChange}
                                onBlur={this._handlePasswordBlur}/>


                            <div className="button-wrap">

                                <div className={errorClasses}>
                                    {this.state.errorMessage}
                                </div>

                                <Spinner width="40px" height="40px" show={this.state.inProgress}/>

                                <RaisedButton
                                    primary={true}
                                    disabled={!this.state.emailValid || !this.state.passwordValid}
                                    onClick={this._handleLogin}
                                    className={loginButtonClass}
                                    label="Login"/>
                            </div>

                            <div className='secondary-buttons'>
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