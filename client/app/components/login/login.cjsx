React = require('react')
{Paper, TextField, RaisedButton, FlatButton} =  require('material-ui');
userActions = require('../../actions/UserActions.es6')
userStore = require('../../stores/UserStore.es6')
Spinner = require('../spinner/spinner.jsx')
classBuilder = require('classnames')
style = require('./login.styl')

Login = React.createClass(
    getInitialState: ->
        email: ''
        password: ''
        nameValid: ''
        emailValid: false
        passwordValid: false
        emailErrorText: ''
        nameErrorText: ''
        passwordErrorText: ''
        inProgress: userStore.InProgress
        error: ''
        needVerification: false
        isLogin: true
        name: getParameterByName 'name'

    componentDidMount: ->
        userStore.addChangeListener @_onChange

    componentWillUnmount: ->
        userStore.removeChangeListener @_onChange

    _onChange: ->
        @setState getState()

    _handleEmailBlur: (e) ->
        errorMsg = ''
        if !e.target.value
            errorMsg = 'email is required'
        else if validateEmail(e.target.value) == false
            errorMsg = 'email is not valid'
        isValid = errorMsg == ''
        @setState
            emailErrorText: errorMsg
            emailValid: isValid

    _handlePasswordBlur: (e) ->
        errorMsg = if e.target.value then '' else 'password is required'
        isValid = errorMsg == ''
        @setState
            passwordErrorText: errorMsg
            passwordValid: isValid

    _handleNameBlur: (e) ->
        errorMsg = if e.target.value then '' else 'name required'
        isValid = errorMsg == ''
        @setState
            nameErrorText: errorMsg
            nameValid: isValid

    _handleNameChange: (e) ->
        @name = e.target.value

    _handleEmailChange: (e) ->
        @email = e.target.value

    _handlePasswordChange: (e) ->
        @password = e.target.value
        isValid = e.target.value.length
        if !@state.passwordValid
            @setState
                password: e.target.value
                passwordValid: isValid
                
    _formValid: ->
        @state.emailValid and @state.passwordValid

    _handleLogin: (e) ->
        e.preventDefault()

        formData =
            email: @email
            password: @password

        if @state.isLogin
            if @_formValid()
                userActions.login formData
        else
            formData.name = @name
            if @state.nameValid and @_formValid()
                userActions.register formData

    _handePasswordRecovery: ->
        console.log 'forgot password clicked'

    _handleSwitchForm: ->
        @setState isLogin: !@state.isLogin

    _getName: ->
        getParameterByName 'name'

    render: ->
        loginButtonClass = classBuilder
            loginButton: true
            hide: @state.inProgress

        errorClasses = classBuilder 
            autherror:true
            hide: not @state.hasError

        switchButtonLabel = if @state.isLogin then 'register' else 'login'
        primaryButtonLabel = if @state.isLogin then 'login' else 'register'
        greeting = "Welcome, #{@state.name} ! Please log in to finish registration"

        <div className="login-wrap">
            <h1 className="login-header">SMS Gateway</h1>
            {
                if @state.name then <h4 className="login-subheader">{greeting}</h4> else ''
            }

            <form className="login-form" onSubmit={@_handleLogin}>
                <Paper zDepth={1}>
                    <div className="padded">
                        <div className={classBuilder({verify:true, hidden: !@state.needVerification})}>
                            <h3>almost done...</h3>
                            <h4>Please check your mailbox to verify email address.</h4>
                        </div>
                        <div className={classBuilder({hidden: @state.needVerification})}>
                            {  if @state.isLogin then '' else
                                <TextField
                                    hintText="Enter your name"
                                    errorText={@state.nameErrorText}
                                    floatingLabelText="Your Name"
                                    onChange={@_handleNameChange}
                                    ref="emailInput"
                                    onBlur={@_handleNameBlur}/>
                            }

                            <TextField
                                hintText="Enter your email"
                                errorText={@state.emailErrorText}
                                floatingLabelText="Email"
                                onChange={@_handleEmailChange}
                                ref="emailInput"
                                onBlur={@_handleEmailBlur}/>

                            <TextField
                                hintText="Enter your password"
                                errorText={@state.passwordErrorText}
                                floatingLabelText="Password"
                                type="password"
                                onChange={@_handlePasswordChange}
                                onBlur={@_handlePasswordBlur}/>


                            <div className="button-wrap">

                                <div className={errorClasses}>
                                    {@state.errorMessage}
                                </div>

                                <Spinner width="40px" height="40px" show={@state.inProgress}/>

                                <RaisedButton
                                    primary={true}
                                    disabled={!@state.emailValid or !@state.passwordValid}
                                    onClick={@_handleLogin}
                                    className={loginButtonClass}
                                    label={primaryButtonLabel}/>
                            </div>

                            <div className='secondary-buttons'>
                                <FlatButton linkButton={true} secondary={true} className="switch-form-button" onClick={@_handleSwitchForm} label={switchButtonLabel}/>
                                <FlatButton linkButton={true} secondary={true} className="forgot-button" onClick={@_handePasswordRecovery} label="Forgot the password?"/>
                            </div>
                        </div>
                    </div>
                </Paper>
            </form>
        </div>
)

getState = ->
    inProgress: userStore.InProgress
    hasError: userStore.AuthError.hasError
    errorMessage: userStore.AuthError.message
    needVerification: userStore.NeedVerification
    name: getParameterByName 'name'

validateEmail = (email) ->
    re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
    re.test email

getParameterByName = (name) ->
    name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
    regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
    results = regex.exec(location.search)
    if results == null then '' else decodeURIComponent(results[1].replace(/\+/g, ' '))
    
module.exports = Login
