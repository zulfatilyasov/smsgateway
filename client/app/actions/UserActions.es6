import AppDispatcher from '../AppDispatcher';
import UserContstants from '../constants/UserConstants.js';
import apiClient  from '../services/apiclient.es6';

var loginDelay = 1000;
var UserActions = {
    login: (creds) => {
        apiClient.login(creds.email, creds.password)
            .then(resp => {
                var data = resp.body;

                setTimeout(() =>{
                    AppDispatcher.handleServerAction({
                        actionType: UserContstants.LOG_IN_SUCCESS,
                        data: data
                    });

                    var accessToken = data.id;
                    apiClient.setToken(accessToken);
                }, loginDelay)

            }, err => {
                setTimeout(()=>{
                    AppDispatcher.handleServerAction({
                        actionType: UserContstants.LOG_IN_FAIL,
                        error: err
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
