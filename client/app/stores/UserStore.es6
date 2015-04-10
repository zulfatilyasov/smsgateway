import BaseStore from './BaseStore.es6';
import userConstants from 'constants/UserConstants';

var storeInstance;

var _isAuthenticated = false;

class UserStore extends BaseStore {
    get isAuthenticated() {
        var token = localStorage.getItem('sg-token');
        return !!token;
    }
}

var actions = {};

actions[userConstants.LOG_IN_SUCCESS] = (action) => {
    localStorage.setItem('sg-token', action.data.id);
    storeInstance.emitChange();
};

actions[userConstants.LOG_OUT] = () => {
    console.log('logout in user store');
    localStorage.removeItem('sg-token');
    storeInstance.emitChange();
};

storeInstance = new UserStore(actions);

module.exports = storeInstance;
