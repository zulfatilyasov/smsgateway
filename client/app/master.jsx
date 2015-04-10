var React = require('react');
var Router = require('react-router');
var RouteHandler = Router.RouteHandler;
var mui = require('material-ui');
var AppBar = mui.AppBar;
var AppCanvas = mui.AppCanvas;
var FontIcon = mui.FontIcon;
var Menu = mui.Menu;
require('./custom.less');
var IconButton = mui.IconButton;
var PageWithNav = require('./page-with-nav.jsx');
var LoginPage = require('./pages/login-page.jsx');
var userStore = require('./stores/UserStore.es6');
var userActions = require('./actions/UserActions.es6');
//require('../static/font-styles.css');

var getState = function () {
    return {
        authenticated: userStore.isAuthenticated
    };
};

var Master = React.createClass({

    mixins: [Router.State],

    getInitialState: function () {
        return getState();
    },

    componentDidMount() {
        userStore.addChangeListener(this._onChange);
    },

    componentWillUnmount() {
        userStore.removeChangeListener(this._onChange);
    },

    _onChange() {
        this.setState(getState());
    },

    _handleLogout: function () {
        userActions.logout();
    },

    render: function () {

        // var title =
        //   this.context.router.isActive('get-started') ? 'Get Started' :
        //   this.context.router.isActive('css-framework') ? 'Css Framework' :
        //   this.context.router.isActive('components') ? 'Components' : '';

        var menuItems = [
            {route: 'dashboard', text: 'Dashboard'},
            {route: 'messages', text: 'Messages'},
            {route: 'contacts', text: 'Contacts'},
            {route: 'settings', text: 'Settings'}
        ];

        var githubButton = (
            <IconButton
                onClick={this._handleLogout}
                tooltip="Logout"
                className="logout-icon-button mui-font-icon icon-exit"/>
        );

        return (
            <AppCanvas predefinedLayout={1}>

                <AppBar
                    className="mui-dark-theme"
                    onMenuIconButtonTouchTap={this._onMenuIconButtonTouchTap}
                    title="SMS Gateway"
                    zDepth={0}>
                    {githubButton}
                </AppBar>

                <PageWithNav menuItems={menuItems}/>

                {
                    this.state.authenticated ? null : <LoginPage />
                }

            </AppCanvas>
        );
    },

    _onMenuIconButtonTouchTap: function () {
        this.refs.leftNav.toggle();
    }

});

module.exports = Master;