var React = require('react'),
    Router = require('react-router'),
    mui = require('material-ui'),
    userActions = require('./actions/UserActions.coffee')


var AppLeftNav = React.createClass({

    mixins: [Router.Navigation, Router.State],

    getInitialState: function () {
        return {
            selectedIndex: null
        };
    },

    _onLogoutClick: function () {
        userActions.logout();
    },

    render: function () {
        var header = <div className="logo" onClick={this._onHeaderClick}>SMS Gateway</div>;

        this.menuItems = [
            {route: 'dashboard', text: 'Dashboard',iconClassName:'icon icon-dashboard'},
            {route: 'allmessages', text: 'Messages',iconClassName:'icon icon-chat'},
            {route: 'allContacts', text: 'Contacts',iconClassName:'icon icon-users'},
            {route: 'settings', text: 'Settings',iconClassName:'icon icon-settings'},
            {route: 'logout', onClick: this._onLogoutClick, text: 'Logout',iconClassName:'icon icon-lock'}
        ];

        return (
            <mui.LeftNav
                ref="leftNav"
                docked={false}
                isInitiallyOpen={false}
                header={header}
                menuItems={this.menuItems}
                selectedIndex={this._getSelectedIndex()}
                onItemClick={this._onLogoutClick}
                onChange={this._onLeftNavChange}/>
        );
    },

    toggle: function () {
        this.refs.leftNav.toggle();
    },

    _getSelectedIndex: function () {
        var currentItem;

        for (var i = this.menuItems.length - 1; i >= 0; i--) {
            currentItem = this.menuItems[i];
            if (currentItem.route && this.context.router.isActive(currentItem.route)) return i;
        }
    },

    _onLeftNavChange: function (e, key, payload) {
        if (payload.onClick) {
            payload.onClick();
        }
        else {
            this.context.router.transitionTo(payload.route);
        }
    },

    _onHeaderClick: function () {
        this.context.router.transitionTo('root');
        this.refs.leftNav.close();
    }

});

module.exports = AppLeftNav;
