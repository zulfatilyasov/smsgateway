import BaseStore from './BaseStore.coffee';
import MessageConstants from '../constants/MessageConstants.js';
import _ from 'lodash';

var storeInstance;

var _messageList = [];
var _messageToResend = null
var _sendInProgress = false;
var _error = '';
var _inProgress = false;

class MessageStore extends BaseStore {
    get InProgress(){
        return _inProgress;
    }

    get MessageList() {
        return _messageList;
    }

    get IsSending() {
        return _sendInProgress;
    }

    get Error() {
        return error;
    }

    get MessageToResend(){
        return _messageToResend
    }
}

var actions = {};

actions[MessageConstants.SEND] = action => {
    _sendInProgress = true;
    storeInstance.emitChange();
};

actions[MessageConstants.SEND_SUCCESS] = action => {
    _sendInProgress = false;
    action.message.new = true;
    _messageToResend = null;
    _messageList.push(action.message);
    storeInstance.emitChange();
};

actions[MessageConstants.SEND_FAIL] = action => {
    _sendInProgress = false;
    _messageList.push({
        id: (new Date()).toUTCString(),
        status: 'failed',
        outcoming: true,
        address: action.message.address,
        body: action.message.body
    });
    _error = action.error;
    storeInstance.emitChange();
};

actions[MessageConstants.MESSAGE_RECEIVED] = action => {
    var message = action.message;
    message.status = 'received';
    message.incoming = true;
    message.new = true;
    _messageList.push(message);
    storeInstance.emitChange();
};

var receivedMessages = action => {
    _messageList = action.messages;
    _inProgress = false;
    storeInstance.emitChange();
};

var getMessagesFail = action => {
    _inProgress = false;
    _error = 'failed to get messages';
    storeInstance.emitChange();
};

var getMessages = action => {
    _inProgress = true;
    storeInstance.emitChange();
};

actions[MessageConstants.RECEIVED_ALL_MESSAGES] = receivedMessages;
actions[MessageConstants.GET_ALL_MESSAGES_FAIL] = getMessagesFail;
actions[MessageConstants.GET_MESSAGES] = getMessages;
actions[MessageConstants.RECEIVED_SEARCHED_MESSAGES] = receivedMessages;
actions[MessageConstants.GET_SEARCHED_MESSAGES_FAIL] = getMessagesFail;
actions[MessageConstants.SEARCH_MESSAGES] = action => {
    _messageList = [];
    storeInstance.emitChange();
};

actions[MessageConstants.MESSAGE_STAR_UPDATED] = action => {
    var message = action.message;
    _messageList = _.map(_messageList, (m) => {
                        return m.id === message.id ? message : m
                    });
    storeInstance.emitChange();
};

actions[MessageConstants.CLEAN] = action => {
    _messageList = [];
};

actions[MessageConstants.RESEND] = action => {
    _messageToResend = action.message;
    storeInstance.emitChange();
};

actions[MessageConstants.CLEARRESEND] = action => {
    _messageToResend = null;
};

storeInstance = new MessageStore(actions);

module.exports = storeInstance;
