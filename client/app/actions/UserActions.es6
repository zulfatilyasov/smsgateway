import AppDispatcher from '../AppDispatcher';
import UserContstants from '../constants/UserConstants.js';
import apiClient  from '../services/apiclient.es6';

var loginDelay = 1000;
var UserActions = {
    register: (registrationData) => {
        apiClient.register(registrationData)
            .then(resp => {

                var data = resp.body;
                setTimeout(() => {
                    AppDispatcher.handleServerAction({
                        actionType: UserContstants.REGISTER_SUCCESS,
                        data: data
                    });
                }, loginDelay);

            }, err => {

                var error  = err.response.body.error;
                setTimeout(() => {
                    AppDispatcher.handleServerAction({
                        actionType: UserContstants.REGISTER_FAIL,
                        error: error
                    });
                }, loginDelay);

            });

        AppDispatcher.handleViewAction({
            actionType: UserContstants.REGISTER,
            registrationData: registrationData
        });
    },

    login: (creds) => {
        apiClient.login(creds.email, creds.password)
            .then(resp => {
                var data = resp.body;

                setTimeout(() => {
                    AppDispatcher.handleServerAction({
                        actionType: UserContstants.LOG_IN_SUCCESS,
                        data: data
                    });
                }, loginDelay)

            }, err => {
                var error  = err.response.body.error;
                setTimeout(()=> {
                    AppDispatcher.handleServerAction({
                        actionType: UserContstants.LOG_IN_FAIL,
                        error: error
                    });
                }, loginDelay);
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
