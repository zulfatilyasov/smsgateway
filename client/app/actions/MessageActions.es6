import AppDispatcher from '../AppDispatcher.coffee';
import MessageContstants from '../constants/MessageConstants.js';
import apiClient  from '../services/apiclient.es6';

var MessageActions = {
    send: (message) => {
        apiClient.sendMessage(message)
            .then(function (resp) {

                setTimeout(function () {
                    AppDispatcher.handleViewAction({
                        actionType: MessageContstants.SEND_SUCCESS,
                        message: message
                    });
                }, 1000);

            }, function (err) {

                setTimeout(function () {
                    AppDispatcher.handleViewAction({
                        actionType: MessageContstants.SEND_FAIL,
                        error: err,
                        message:message
                    });
                }, 1000)
            });

        AppDispatcher.handleViewAction({
            actionType: MessageContstants.SEND,
            message: message
        });
    }
};

module.exports = MessageActions;
