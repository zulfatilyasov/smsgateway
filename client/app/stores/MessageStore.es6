import BaseStore from './BaseStore.coffee';
import MessageConstants from '../constants/MessageConstants.js';

var storeInstance;

var _messageList = [{
    status: 'Sent',
    contact: '+79263233574',
    message: 'lorem impsum'
}, {
    status: 'Sent',
    contact: '+79274608372',
    message: 'hello sms gateway'
}, {
    status: 'Sent',
    contact: '+79274608372',
    message: 'another message'
}, {
    status: 'Sent',
    contact: '+79274608372',
    message: 'How do you do?'
}, {
    status: 'Sent',
    contact: '+79274608372',
    message: 'Get you message delivered'
}, {
    status: 'Sent',
    contact: '+79274608372',
    message: 'this is first'
}];

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
        contact: action.message.recipient,
        message: action.message.text
    });
    storeInstance.emitChange();
};

actions[MessageConstants.SEND_FAIL] = action => {
    _sendInProgress = false;
    _messageList.push({
        status: 'Failed',
        contact: action.message.recipient,
        message: action.message.text
    });
    _error = action.error;
    storeInstance.emitChange();
};

storeInstance = new MessageStore(actions);

module.exports = storeInstance;
