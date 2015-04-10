import Dispatcher from 'flux/lib/Dispatcher';
import assign from 'object-assign';

var AppDispatcher = assign(new Dispatcher(), {

    handleViewAction: function (action) {
        this.dispatch({
            source: 'VIEW_ACTION',
            action: action
        });
    },

    handleServerAction: function (action) {
        this.dispatch({
            source: 'SERVER_ACTION',
            action: action
        });
    }
});

module.exports = AppDispatcher;
