import BaseStore from './BaseStore.coffee';
import MessageConstants from '../constants/MessageConstants.js';

var storeInstance;

var _messageList = [];

var _sendInProgress = false;
var _error = '';

class MessageStore extends BaseStore {
    get MessageList() {
        return _messageList;
    }

    get IsSending() {
        return _sendInProgress;
    }

    get Error() {
        return error;
    }
}

var actions = {};

actions[MessageConstants.SEND] = action => {
    _sendInProgress = true;
    storeInstance.emitChange();
};

actions[MessageConstants.SEND_SUCCESS] = action => {
    _sendInProgress = false;
    _messageList.push({
        status: 'Sent',
        outcoming: true,
        contact: action.message.recipient,
        message: action.message.text
    });
    storeInstance.emitChange();
};

actions[MessageConstants.SEND_FAIL] = action => {
    _sendInProgress = false;
    _messageList.push({
        status: 'Failed',
        outcoming: true,
        contact: action.message.recipient,
        message: action.message.text
    });
    _error = action.error;
    storeInstance.emitChange();
};

actions[MessageConstants.MESSAGE_RECEIVED] = action => {
    _messageList.push({
        status: 'received',
        incoming: true,
        contact: action.message.recipient,
        message: action.message.text
    });
    storeInstance.emitChange();
};

actions[MessageConstants.RECEIVED_ALL_MESSAGES] = action => {
    _messageList = action.messages 
    storeInstance.emitChange();
};

storeInstance = new MessageStore(actions);

module.exports = storeInstance;
