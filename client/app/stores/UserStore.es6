var BaseStore = require('./BaseStore.es6');
var userConstants = require('constants/UserConstants');

var storeInstance;

var _isAuthenticated = '';

class UserStore extends BaseStore {
    get isAuthenticated() {
        return _isAuthenticated;
    }
}

var actions = {};

actions[userConstants.LOG_IN] = () => {
    _isAuthenticated = true;
    storeInstance.emitChange();
};

actions[userConstants.LOG_OUT] = () => {
    _isAuthenticated = false;
    storeInstance.emitChange();
};

storeInstance = new UserStore(actions);

module.exports = storeInstance;
