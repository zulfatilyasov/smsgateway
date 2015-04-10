var BaseStore = require('./BaseStore');
var ExampleConstants = require('constants/ExampleConstants');

var storeInstance;

var _message = '';

class ExampleStore extends BaseStore {
    get message() {
        return _message;
    }
}

var actions = {};

actions[ExampleConstants.SEND_MESSAGE] = action => {
    _message = action.message;
    storeInstance.emitChange();
};

storeInstance = new ExampleStore(actions);

module.exports = storeInstance;
