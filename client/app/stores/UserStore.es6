import BaseStore from './BaseStore.es6';
import userConstants from 'constants/UserConstants';

var storeInstance;

var _authenticationInProgress = false;
var _needVerification = false;
var _authError = {
    hasError: false,
    message: ''
};

class UserStore extends BaseStore {
    get isAuthenticated() {
        var token = localStorage.getItem('sg-token');
        return !!token;
    }

    get InProgress() {
        return _authenticationInProgress;
    }

    get AuthError() {
        return _authError;
    }

    get NeedVerification() {
        return _needVerification;
    }
}

var actions = {};

actions[userConstants.LOG_IN] = (action) => {
    _authenticationInProgress = true;
    _authError.hasError = false;

    storeInstance.emitChange();
};

actions[userConstants.LOG_IN_SUCCESS] = (action) => {
    localStorage.setItem('sg-token', action.data.id);
    _authenticationInProgress = false;

    storeInstance.emitChange();
};

actions[userConstants.LOG_IN_FAIL] = (action) => {
    _authenticationInProgress = false;
    _authError.message = 'Authentication failed';
    _authError.hasError = true;
    if (action.error.status === 401) {
        _authError.message = action.error.code === 'LOGIN_FAILED_EMAIL_NOT_VERIFIED' ? 'Email is not verified' : 'Incorrect email or password';
    }

    storeInstance.emitChange();
};

actions[userConstants.REGISTER] = action => {
    _authenticationInProgress = true;
    _authError.hasError = false;

    storeInstance.emitChange();
};

actions[userConstants.REGISTER_SUCCESS] = action => {
    _authenticationInProgress = false;
    _needVerification = true;

    storeInstance.emitChange();
};

actions[userConstants.REGISTER_FAIL] = action => {
    _authenticationInProgress = false;

    _authError.message = 'Registration failed. Check your data';
    _authError.hasError = true;

    storeInstance.emitChange();
};

actions[userConstants.LOG_OUT] = () => {
    localStorage.removeItem('sg-token');
    storeInstance.emitChange();
};

storeInstance = new UserStore(actions);

module.exports = storeInstance;
