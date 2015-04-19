React = rquire('react')
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
        className = if @state.inProgress then 'hide' else ''
        loginButtonClass = 'login-button ' + className
        errorClasses = 'auth-error'
        errorClasses += if @state.hasError then '' else ' hide'
        switchButtonLabel = if @state.isLogin then 'register' else 'login'
        primaryButtonLabel = if @state.isLogin then 'login' else 'register'
        name = @_getName()
        greeting = 'Welcome, ' + name + '! Please log in to finish registration'
)

getState = ->
    inProgress: userStore.InProgress
    hasError: userStore.AuthError.hasError
    errorMessage: userStore.AuthError.message
    needVerification: userStore.NeedVerification

validateEmail = (email) ->
    re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
    re.test email

getParameterByName = (name) ->
    name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]')
    regex = new RegExp('[\\?&]' + name + '=([^&#]*)')
    results = regex.exec(location.search)
    if results == null then '' else decodeURIComponent(results[1].replace(/\+/g, ' '))

module.exports = Login
