var BaseStore = require('./BaseStore');
var MessageConstants = require('constants/MessgeConstants');

var storeInstance;

var _messageList = '';

class MessageStore extends BaseStore {
    get messageList() {
        return _messageList;
    }
}

var actions = {};

actions[MessageConstants.SEND] = action => {
    _messageList.push(action.message);
    storeInstance.emitChange();
};

storeInstance = new MessageStore(actions);

module.exports = storeInstance;
