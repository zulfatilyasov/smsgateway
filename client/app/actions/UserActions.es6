var AppDispatcher = require('../AppDispatcher');
var UserContstants = require('../constants/UserConstants.js');

var UserActions = {

    login:() => {
        console.log('login action');
        AppDispatcher.handleViewAction({
            actionType: UserContstants.LOG_IN
        });
    },

    logout:() => {
        AppDispatcher.handleViewAction({
            actionType: UserContstants.LOG_OUT
        });
    }

};

module.exports = UserActions;
