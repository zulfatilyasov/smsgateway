React = require('react')
{Paper, TextField, RaisedButton, FlatButton} =  require('material-ui');
userActions = require('../../actions/UserActions.coffee')
messageActions = require('../../actions/MessageActions.coffee')
userStore = require('../../stores/UserStore.coffee')
Spinner = require('../spinner/spinner.cjsx')
classBuilder = require('classnames')
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'
style = require('./login.styl')

Login = React.createClass
    getInitialState: ->
        @accessToken = getParameterByName 'access_token'
        state = 
            formValid:false
            email: ''
            password: ''
            nameValid: true
            emailValid: false
            passwordValid: false
            confirmationValid: false
            emailErrorText: ''
            nameErrorText: ''
            passwordErrorText: ''
            inProgress: userStore.InProgress()
            error: ''
            needVerification: false
            isLogin: !@accessToken
            isRegister: false
            isRequestReset:false
            isResetPassword: !!@accessToken
            name: getParameterByName 'name'
            isNewPassword: getParameterByName 'name'

        if state.isResetPassword
            state.primaryButtonLabel =  'save'
            state.leftButtonLabel = 'login'
            state.rightButtonLabel = 'register'
            state.primaryClickHandler =  @_savePasswordlickHandler
            state.leftClickHandler =  @_setStateLogin
            state.rightClickHandler =  @_setStateRegister
        else
            state.primaryButtonLabel =  'login'
            state.leftButtonLabel = 'register'
            state.rightButtonLabel = 'Forgot your password?'
            state.primaryClickHandler =  @_loginClickHandler
            state.leftClickHandler =  @_setStateRegister
            state.rightClickHandler =  @_setStateResetPassword

        state

    componentDidMount: ->
        userStore.addChangeListener @_onChange

    componentWillUnmount: ->
        userStore.removeChangeListener @_onChange
        messageActions.startReceiving()
        userActions.startWatchingDevice()
        userActions.getUserDevice()

    _onChange: ->
        console.log 'called on changed login'
        @setState(@getState())

    getState: ->
        passwordResetSucceeded = userStore.PasswordResetSucceeded()
        state = {}
        if passwordResetSucceeded
            history.replaceState({}, 'login', '/');
            state = @getInitialState()
            state.info = 'Please login in with your new password'
        else
            state =
                inProgress: userStore.InProgress()
                hasError: userStore.AuthError().hasError
                errorMessage: userStore.AuthError().message
                needVerification: userStore.NeedVerification()
                requestedPasswordReset:userStore.RequestedPasswordReset()
                name: getParameterByName 'name'
                
        return state

    _handleEmailBlur: (e) ->
        errorMsg = ''
        if !@email?.length
            errorMsg = 'email is required'
        else if validateEmail(@email) == false
            errorMsg = 'email is not valid'
        isValid = errorMsg == ''

        @setState
            emailErrorText: errorMsg
            emailValid: isValid
            formValid: isValid && @state.nameValid && @state.passwordValid

    _setStateRegister: ->
        @setState 
            isLogin: false
            isRegister: true
            isRequestReset: false
            isResetPassword: false
            nameValid: false
            primaryClickHandler:@_registerClickHandler
            leftClickHandler:@_setStateLogin
            rightClickHandler:@_setStateResetPassword
            primaryButtonLabel: 'register',
            leftButtonLabel:'login',
            rightButtonLabel:'Forgot your password?'

    _setStateLogin: ->
        @setState 
            isLogin: true
            isRegister: false
            isRequestReset: false
            isResetPassword: false
            nameValid: true
            primaryClickHandler:@_loginClickHandler
            leftClickHandler:@_setStateRegister
            rightClickHandler:@_setStateResetPassword
            primaryButtonLabel: 'login',
            leftButtonLabel:'register',
            rightButtonLabel:'Forgot your password?'

    _setStateResetPassword: ->
        @setState 
            isLogin: false
            isRegister: false
            isRequestReset: true
            isResetPassword:false
            formValid: true
            nameValid: true
            passwordValid: true
            primaryClickHandler: @_resetPasswordClickHandler
            leftClickHandler: @_setStateLogin
            rightClickHandler: @_setStateRegister
            primaryButtonLabel: 'reset password',
            leftButtonLabel:'login',
            rightButtonLabel:'register'

    _handlePasswordBlur: (e) ->
        errorMsg = if @password?.length then '' else 'password is required'
        isValid = errorMsg == ''
        @setState
            passwordErrorText: errorMsg
            passwordValid: isValid

    _handleNameBlur: (e) ->
        errorMsg = if e.target.value then '' else 'name required'
        @setState
            nameErrorText: errorMsg
            nameValid: errorMsg == ''

    _handleNameChange: (e) ->
        @name = e.target.value

    _handleEmailChange: (e) ->
        @email = e.target.value
        @emailErrorMessage = ''
        if !@email?.length
            @emailErrorMessage = 'email is required'
        else if validateEmail(@email) == false
            @emailErrorMessage = 'email is not valid'

        @setState
            formValid: @email.length && @state.passwordValid

    _handlePasswordChange: (e) ->
        @password = e.target.value
        passwordValid = e.target.value.length
        if !@state.passwordValid
            @setState
                passwordValid: passwordValid
                formValid: passwordValid && @state.emailValid && @state.nameValid

    _validateNewPassword: ->
        passwordError = ''
        confirmationError = ''
        if not @password?.length
            passwordError = 'password required'

        if @password?.length and @password?.length < 6
            passwordError = 'password length min 6 characters'

        if @password?.length and @confirmation?.length and @confirmation isnt @password
            confirmationError = 'passwords don\'t match'

        formValid = @password?.length and @confirmation?.length and !confirmationError and !passwordError

        @setState
            passwordValid: !passwordError
            passwordErrorText: passwordError
            confirmationValid: !confirmationError
            confirmationErrorText: confirmationError
            formValid: formValid

    _handleNewPasswordChange: (e) ->
        @password = e.target.value
        @_validateNewPassword()

    _handleConfirmationChange: (e) ->
        @confirmation = e.target.value
        @_validateNewPassword()

    _savePasswordlickHandler: (e) ->
        e.preventDefault()

        if @state.formValid
            userActions.resetPassword @accessToken, @password, @confirmation
    
    _loginClickHandler: (e) ->
        e.preventDefault()

        if @emailErrorMessage
            @setState
                emailErrorText: emailErrorMessage
                emailValid: false
            return

        formData =
            email: @email
            password: @password

        if @state.formValid
            userActions.login formData

    _registerClickHandler: (e) ->
        e.preventDefault()

        formData =
            email: @email
            password: @password
            name: @name

        if @state.formValid 
            userActions.register formData

    _resetPasswordClickHandler: (e) ->
        e.preventDefault()

        formData =
            email: @email

        if @state.formValid
            userActions.requestResetPassword formData

    _getName: ->
        getParameterByName 'name'

    render: ->
        loginButtonClass = classBuilder
            loginButton: true
            hide: @state.inProgress

        errorClasses = classBuilder 
            autherror:true
            hide: not @state.hasError

        greeting = "Welcome, #{@state.name} ! Please log in to finish registration"
        if @state.info
            greeting = @state.info

        <div className="login-wrap">
            <h1 className="login-header">SMS Gateway</h1>
            {
                if @state.name or @state.info then <h4 className="login-subheader">{greeting}</h4> else ''
            }
            <form className="login-form" onSubmit={@_handleLogin}>
                <Paper zDepth={1}>
                    <div className="padded">
                        <div className={classBuilder({verify:true, hidden: !@state.needVerification})}>
                            <h3>almost done...</h3>
                            <h4>Please check your mailbox to verify email address.</h4>
                        </div>
                        <div className={classBuilder({verify:true, hidden: !@state.requestedPasswordReset})}>
                            <h3>Check you email</h3>
                            <h4>A link to reset your password was sent to your email</h4>
                        </div>
                        <div className={classBuilder({hidden: @state.needVerification or @state.requestedPasswordReset})}>
                            {
                                if @state.isRegister 
                                    <TextField
                                        hintText="Enter your name"
                                        errorText={@state.nameErrorText}
                                        floatingLabelText="Your Name"
                                        onChange={@_handleNameChange}
                                        ref="emailInput"
                                        onBlur={@_handleNameBlur}/> 
                            }

                            {
                                if @state.isRegister or @state.isLogin or @state.isRequestReset
                                    <TextField
                                        className="email-input"
                                        hintText="Enter your email"
                                        errorText={@state.emailErrorText}
                                        floatingLabelText="Email"
                                        onChange={@_handleEmailChange}
                                        ref="emailInput"
                                        onBlur={@_handleEmailBlur}/>
                            }

                            {
                                if @state.isRegister or @state.isLogin
                                    <TextField
                                        className="password-input"
                                        hintText="Enter your password"
                                        errorText={@state.passwordErrorText}
                                        floatingLabelText="Password"
                                        type="password"
                                        onChange={@_handlePasswordChange}
                                        onBlur={@_handlePasswordBlur}/>
                            }

                            {
                                if @state.isResetPassword
                                    <div className="resetPassword">
                                        <h2>Choose your new password</h2>
                                        <TextField
                                            hintText="Enter new password"
                                            errorText={@state.passwordErrorText}
                                            floatingLabelText="New password"
                                            type="password"
                                            onBlur={@_validateNewPassword}
                                            onChange={@_handleNewPasswordChange}/>

                                        <TextField
                                            hintText="Enter password again"
                                            errorText={@state.confirmationErrorText}
                                            floatingLabelText="Password Confirmation"
                                            type="password"
                                            onChange={@_handleConfirmationChange}/>
                                    </div>
                            }


                            <div className="button-wrap">

                                <div className={errorClasses}>
                                    {@state.errorMessage}
                                </div>

                                <Spinner width="40px" height="40px" show={@state.inProgress}/>

                                <RaisedButton
                                    primary={true}
                                    disabled={!@state.formValid}
                                    onClick={@state.primaryClickHandler}
                                    className={loginButtonClass}
                                    label={@state.primaryButtonLabel}/>
                            </div>

                            <div className='secondary-buttons'>
                                <FlatButton
                                    linkButton={true}
                                    secondary={true}
                                    className="switch-form-button"
                                    onClick={@state.leftClickHandler}
                                    label={@state.leftButtonLabel}/>

                                <FlatButton
                                    linkButton={true}
                                    secondary={true}
                                    className="forgot-button"
                                    onClick={@state.rightClickHandler}
                                    label={@state.rightButtonLabel}/>
                            </div>
                        </div>
                    </div>
                </Paper>
            </form>
        </div>

validateEmail = (email) ->
    re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
    re.test email

getParameterByName = (name) ->
    name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
    regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
    results = regex.exec(location.search)
    if results == null then '' else decodeURIComponent(results[1].replace(/\+/g, ' '))
    
module.exports = Login
