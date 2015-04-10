import AppDispatcher from '../AppDispatcher';
import UserContstants from '../constants/UserConstants.js';
import apiClient  from '../services/apiclient.es6';

var UserActions = {

    login: (creds) => {
        apiClient.login(creds.email, creds.password)
            .then(resp => {
                var data = resp.body;

                AppDispatcher.handleServerAction({
                    actionType: UserContstants.LOG_IN_SUCCESS,
                    data: data
                });

                var accessToken = data.id;
                apiClient.setToken(accessToken);

            }, err => {
                AppDispatcher.handleServerAction({
                    actionType: UserContstants.LOG_IN_FAIL,
                    error: err
                });
            });

        AppDispatcher.handleViewAction({
            actionType: UserContstants.LOG_IN,
            creds: creds
        });
    },

    logout: () => {
        AppDispatcher.handleViewAction({
            actionType: UserContstants.LOG_OUT
        });
    }

};

module.exports = UserActions;
