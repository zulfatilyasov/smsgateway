import React from 'react';
import {Paper, TextField, RaisedButton, FlatButton} from 'material-ui';
import userActions  from '../../actions/UserActions.es6';
import userStore from '../../stores/UserStore.es6'
import Spinner from '../spinner/spinner.jsx'
import classBuilder from 'classnames';
import style from './login.styl'


function getState() {
    return {
        inProgress: userStore.InProgress,
        hasError: userStore.AuthError.hasError,
        errorMessage: userStore.AuthError.message,
        needVerification: userStore.NeedVerification
    };
}

var Login = React.createClass({

    getInitialState: function () {
        return {
            email: '',
            password: '',
            nameValid: '',
            emailValid: false,
            passwordValid: false,
            emailErrorText: '',
            nameErrorText: '',
            passwordErrorText: '',
            inProgress: userStore.InProgress,
            error: '',
            needVerification: false,
            isLogin: true

        };
    },

    componentDidMount: function () {
        userStore.addChangeListener(this._onChange);
    },

    componentWillUnmount: function () {
        userStore.removeChangeListener(this._onChange);
    },

    _onChange: function () {
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
        var errorMsg = e.target.value ? '' : 'password is required';
        var isValid = errorMsg === '';

        this.setState({passwordErrorText: errorMsg, passwordValid: isValid});
    },

    _handleNameBlur: function (e) {
        var errorMsg = e.target.value ? '' : 'name required';
        var isValid = errorMsg === '';

        this.setState({nameErrorText: errorMsg, nameValid: isValid});
    },

    _handleNameChange: function (e) {
        this.name = e.target.value;
    },

    _handleEmailChange: function (e) {
        this.email = e.target.value;
    },

    _handlePasswordChange: function (e) {
        this.password = e.target.value;

        var isValid = e.target.value.length;

        if (!this.state.passwordValid) {
            this.setState({password: e.target.value, passwordValid: isValid});
        }
    },

    _formValid: function () {
        return this.state.emailValid && this.state.passwordValid;
    },

    _handleLogin: function (e) {
        e.preventDefault();

        var formData = {
            email: this.email,
            password: this.password
        };

        if (this.state.isLogin) {
            if (this._formValid()) {
                userActions.login(formData);
            }
        }
        else {
            formData.name = this.name;
            if (this.state.nameValid && this._formValid()) {
                userActions.register(formData);
            }
        }
    },

    _handePasswordRecovery: function () {
        console.log('forgot password clicked');
    },

    _handleSwitchForm: function () {
        this.setState({isLogin: !this.state.isLogin});
    },

    _getName: function () {
        return getParameterByName('name');
    },

    render: function () {
        var className = this.state.inProgress ? 'hide' : '';
        var loginButtonClass = 'login-button ' + className;

        var errorClasses = 'auth-error';
        errorClasses += this.state.hasError ? '' : ' hide';

        var switchButtonLabel = this.state.isLogin ? 'register' : 'login';
        var primaryButtonLabel = this.state.isLogin ? 'login' : 'register';

        var name = this._getName();
        var greeting = 'Welcome, ' + name + '! Please log in to finish registration';

        return (
            <div className="login-wrap">
                <h1 className="login-header">SMS Gateway</h1>
                {
                    name ? <h4 className="login-subheader">{greeting}</h4> : ''
                }

                <form className="login-form" onSubmit={this._handleLogin}>
                    <Paper zDepth={1}>
                        <div className="padded">
                            <div className={classBuilder({verify:true, hidden: !this.state.needVerification})}>
                                <h3>almost done...</h3>
                                <h4>Please check your mailbox to verify email address.</h4>
                            </div>
                            <div className={classBuilder({hidden: this.state.needVerification})}>
                                { this.state.isLogin ? '' :
                                    <TextField
                                        hintText="Enter your name"
                                        errorText={this.state.nameErrorText}
                                        floatingLabelText="Your Name"
                                        onChange={this._handleNameChange}
                                        ref="emailInput"
                                        onBlur={this._handleNameBlur}/>
                                }

                                <TextField
                                    hintText="Enter your email"
                                    errorText={this.state.emailErrorText}
                                    floatingLabelText="Email"
                                    onChange={this._handleEmailChange}
                                    ref="emailInput"
                                    onBlur={this._handleEmailBlur}/>

                                <TextField
                                    hintText="Enter your password"
                                    errorText={this.state.passwordErrorText}
                                    floatingLabelText="Password"
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
                                        label={primaryButtonLabel}/>
                                </div>

                                <div className='secondary-buttons'>
                                    <FlatButton linkButton={true} secondary={true} className="switch-form-button" onClick={this._handleSwitchForm} label={switchButtonLabel}/>
                                    <FlatButton linkButton={true} secondary={true} className="forgot-button" onClick={this._handePasswordRecovery} label="Forgot the password?"/>
                                </div>
                            </div>
                        </div>
                    </Paper>
                </form>
            </div>
        );
    }
});

function validateEmail(email) {
    var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
    return re.test(email);
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
module.exports = Login;