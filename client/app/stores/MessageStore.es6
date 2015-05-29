import BaseStore from './BaseStore.coffee';
import MessageConstants from '../constants/MessageConstants.js';
import _ from 'lodash';

var storeInstance;

var _messageList = [];
var _messageToResend = null
var _sendInProgress = false;
var _error = '';
var _inProgress = false;
var _hasMore = true;

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

    get HasMore(){
        return _hasMore;
    }

    get Error() {
        return error;
    }

    get MessageToResend(){
        return _messageToResend
    }

    selectedMessageIds(){
        return _.pluck(_.filter(_messageList, {'checked': true}), 'id')
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

actions[MessageConstants.SEND_MULTIPLE_SUCCESS] = action => {
    _sendInProgress = false;
    if(action.messages && action.messages.length > 0 && action.messages.length < 100){
        for (var i = action.messages.length - 1; i >= 0; i--) {
            action.messages[i].new = true;
        };
        _messageList =action.messages.concat(_messageList);
    }
    _messageToResend = null;
    storeInstance.emitChange();
};

actions[MessageConstants.SELECT_ALL] = action => {
    for(let message of _messageList){
        message.checked = action.value;
    }
    storeInstance.emitChange();
}

actions[MessageConstants.DELETED_MESSAGES] = action => {
    var deletedIds = action.messageIds;
    _messageList = _.reject(_messageList,  function(m) {
        return _.includes(deletedIds, m.id);
    });
    storeInstance.emitChange();
}

actions[MessageConstants.SELECT] = action => {
    for(let message of _messageList){
        if(message.id === action.messageId){
            message.checked = !message.checked;
        }
    }
}

actions[MessageConstants.SEND_FAIL] = action => {
    _sendInProgress = false;
    _messageList.push({
        id: (new Date()).toUTCString(),
        status: 'failed',
        new:true,
        outcoming: true,
        address: action.message.address,
        body: action.message.body
    });
    _error = action.error;
    storeInstance.emitChange();
};

actions[MessageConstants.SEND_MULTIPLE_FAIL] = action => {
    _sendInProgress = false;
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
    if(action.messages.length < 50){
        _hasMore = false
    }

    _messageList =  action.skiped>0 ? _messageList.concat(action.messages) : action.messages
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

var updateMessage = action => {
    var message = action.message;
    _messageList = _.map(_messageList, (m) => {
                        return m.id === message.id ? message : m
                    });
    storeInstance.emitChange();
};

actions[MessageConstants.RECEIVED_ALL_MESSAGES] = receivedMessages;
actions[MessageConstants.GET_ALL_MESSAGES_FAIL] = getMessagesFail;
actions[MessageConstants.GET_MESSAGES] = getMessages;
actions[MessageConstants.RECEIVED_SEARCHED_MESSAGES] = receivedMessages;
actions[MessageConstants.GET_SEARCHED_MESSAGES_FAIL] = getMessagesFail;
actions[MessageConstants.UPDATE_MESSAGE] = updateMessage;
actions[MessageConstants.MESSAGE_STAR_UPDATED] = updateMessage;

actions[MessageConstants.SEARCH_MESSAGES] = action => {
    _messageList = [];
    storeInstance.emitChange();
};

actions[MessageConstants.MESSAGE_DELETED] = action => {
    _.remove(_messageList, { id : action.messageId });
    storeInstance.emitChange();
};

actions[MessageConstants.RESEND_MESSAGES_SUCCESS] = action => {
    for (let message of action.messages){
        message.new = true;
        _messageList.push(message);
    }
    storeInstance.emitChange();
};

actions[MessageConstants.MESSAGES_CANCEL_SUCCESS] = action => {
    for (let message of _messageList){
        if(_.includes(action.messageIds, message.id) && message.status === 'queued'){
            message.status = 'cancelled';
        }
    }
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
