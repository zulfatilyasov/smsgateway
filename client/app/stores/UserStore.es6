import BaseStore from './BaseStore.es6';
import userConstants from 'constants/UserConstants';

var storeInstance;

var _isAuthenticated = false;
var _authenticationInProgress = false;
var _authError = {
  hasError:false,
  message:''
};

class UserStore extends BaseStore {
    get isAuthenticated() {
        var token = localStorage.getItem('sg-token');
        return !!token;
    }
    get InProgress(){
        return _authenticationInProgress;
    }

    get AuthError(){
        return _authError;
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

    var errorMessage = action.error.status === 401 ? 'Incorrect email or password': 'Authentication failed'; 
    _authError.message = errorMessage;
    _authError.hasError = true; 

    storeInstance.emitChange();
};

actions[userConstants.LOG_OUT] = () => {
    localStorage.removeItem('sg-token');
    storeInstance.emitChange();
};

storeInstance = new UserStore(actions);

module.exports = storeInstance;
