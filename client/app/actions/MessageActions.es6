import AppDispatcher from '../AppDispatcher';
import MessageContstants from '../constants/MessageConstants.js';
import apiClient  from '../services/apiclient.es6';

var MessageActions = {
    send: (message) => {
        apiClient.sendMessage(message)
            .then(function(resp){

                AppDispatcher.handleViewAction({
                    actionType: MessageContstants.SEND_SUCCESS,
                    message:message
                });

            },function (err) {
                
                AppDispatcher.handleViewAction({
                    actionType: MessageContstants.SEND_FAIL,
                    message:message
                });
            });

        AppDispatcher.handleViewAction({
            actionType: MessageContstants.SEND,
            message:message
        });
    }
};

module.exports = MessageActions;
