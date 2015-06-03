BaseStore = require './BaseStore.coffee';
userConstants = require '../constants/UserConstants.js';

_authenticationInProgress = false
_needVerification = false
_requestedPasswordReset = false
_passwordResetSucceeded = false
_deviceModel = null
_snackMessage = null
_authError = 
    hasError: false
    message: ''

class UserStore extends BaseStore
    constructor:(actions) ->
        super(actions)

        @isAuthenticated = ->
           token = localStorage.getItem 'sg-token'
           userId = localStorage.getItem 'sg-userId'
           return userId and token

        @InProgress = ->
            _authenticationInProgress

        @AuthError = ->
            _authError

        @NeedVerification = ->
            _needVerification

        @RequestedPasswordReset = ->
            _requestedPasswordReset

        @PasswordResetSucceeded = ->
            _passwordResetSucceeded

        @userId = ->
            localStorage.getItem 'sg-userId'

        @snackMessage = ->
            _snackMessage

        @deviceModel = ->
            _deviceModel

actions = {}

actions[userConstants.LOG_IN] = (action) ->
    _authenticationInProgress = true
    _authError.hasError = false
    _passwordResetSucceeded = false
    storeInstance.emitChange()

actions[userConstants.LOG_IN_SUCCESS] = (action) ->
    localStorage.setItem 'sg-token', action.data.id
    localStorage.setItem 'sg-userId', action.data.userId
    _authenticationInProgress = false
    storeInstance.emitChange()

actions[userConstants.LOG_IN_FAIL] = (action) -> 
    _authenticationInProgress = false
    _authError.message = 'Authentication failed'
    _authError.hasError = true
    if action.error.status == 401
        _authError.message = if action.error.code ==  'LOGIN_FAILED_EMAIL_NOT_VERIFIED' then 'Email is not verified' else 'Incorrect email or password'
    storeInstance.emitChange()

actions[userConstants.REGISTER] = (action) ->
    _authenticationInProgress = true
    _passwordResetSucceeded = false
    _authError.hasError = false
    storeInstance.emitChange()

actions[userConstants.REGISTER_SUCCESS] = (action) -> 
    _authenticationInProgress = false
    _needVerification = true
    storeInstance.emitChange()

actions[userConstants.REGISTER_FAIL] = (action) ->
    _authenticationInProgress = false
    _authError.message = 'Registration failed. Check your data'
    _authError.hasError = true
    storeInstance.emitChange()

actions[userConstants.RESET_PASSWORD] = (action) ->
    _authenticationInProgress = true
    _authError.hasError = false
    storeInstance.emitChange()

actions[userConstants.RESET_PASSWORD_SUCCESS] = (action) -> 
    _authenticationInProgress = false
    _requestedPasswordReset = true
    storeInstance.emitChange()

actions[userConstants.RESET_PASSWORD_FAIL] = (action) ->
    _authenticationInProgress = false
    _authError.message = 'Password reset failed'
    _authError.hasError = true
    storeInstance.emitChange()

actions[userConstants.SET_PASSWORD] = (action) ->
    _authenticationInProgress = true
    _authError.hasError = false
    storeInstance.emitChange()

actions[userConstants.SET_PASSWORD_SUCCESS] = (action) -> 
    _authenticationInProgress = false
    _passwordResetSucceeded = true
    storeInstance.emitChange()

actions[userConstants.SET_PASSWORD_FAIL] = (action) ->
    _authenticationInProgress = false
    _passwordResetSucceeded = false
    _authError.message = 'Password reset failed'
    _authError.hasError = true
    storeInstance.emitChange()

actions[userConstants.LOG_OUT] = ->
    localStorage.removeItem 'sg-token'
    storeInstance.emitChange()

actions[userConstants.SHOW_SNACK] = (action) ->
    _snackMessage = action.message
    storeInstance.emitChange()

actions[userConstants.DEVICE_CONNECTED] = (action) ->
    _deviceModel = action.deviceModel
    _snackMessage = 'Connected device ' + _deviceModel
    storeInstance.emitChange()

actions[userConstants.DEVICE_DISCONNECTED] = (action) ->
    console.log 'device diconnected'
    if action.deviceModel is _deviceModel
        _deviceModel = null
    _snackMessage = 'Disconnected device ' + action.deviceModel
    storeInstance.emitChange()

storeInstance = new UserStore(actions)

module.exports = storeInstance
