var React = require('react');
var Router = require('react-router');
var RouteHandler = Router.RouteHandler;
var mui = require('material-ui');
var AppBar = mui.AppBar;
var AppCanvas = mui.AppCanvas;
var FontIcon = mui.FontIcon;
var Menu = mui.Menu;
var IconButton = mui.IconButton;
var PageWithNav = require('./page-with-nav.jsx');
var LoginPage = require('./components/login/login-page.cjsx');
var userStore = require('./stores/UserStore.coffee');
var userActions = require('./actions/UserActions.coffee');
var FloatingActionButton = mui.FloatingActionButton;
var MenuButton = require('./components/menu-button/menu-button.jsx');
var AppLeftNav = require('./app-left-nav.jsx');
var messageActions = require('./actions/MessageActions.coffee');

var getState = function () {
    return {
        authenticated: userStore.isAuthenticated()
    };
};

var Master = React.createClass({

    mixins: [Router.State],

    getInitialState(){
        return {
            mounted: false,
            authenticated: userStore.isAuthenticated()
        };
    },

    componentDidMount() {
        messageActions.startReceiving();
        this.setState({
            mounted: true,
            authenticated: userStore.isAuthenticated()
        });
        userStore.addChangeListener(this._onChange);
    },

    componentWillUnmount() {
        this.setState({mounted:false});
        console.log('masterjsx will unmounted')
        userStore.removeChangeListener(this._onChange);
    },

    _onChange() {
        if(this.state.mounted){
            console.log('called on changed master')
            this.setState(getState());
        }
    },

    _onMenuIconButtonTouchTap() {
        this.refs.leftNav.toggle();
    },

    render() {

        // var title =
        //   this.context.router.isActive('get-started') ? 'Get Started' :
        //   this.context.router.isActive('css-framework') ? 'Css Framework' :
        //   this.context.router.isActive('components') ? 'Components' : '';

        var menuItems = [
            {route: 'dashboard', text: 'Dashboard', iconClassName:'icon icon-dashboard'},
            {route: 'messages', text: 'Messages',iconClassName:'icon icon-chat'},
            {route: 'contacts', text: 'Contacts',iconClassName:'icon icon-users'},
            {route: 'settings', text: 'Settings',iconClassName:'icon icon-settings'}
        ];


        var pageContent = <div>
        </div>
        return (
            <AppCanvas>

                <AppBar
                    className="mui-dark-theme"
                    onMenuIconButtonTouchTap={this._onMenuIconButtonTouchTap}
                    showMenuIconButton={false}
                    title="SMS Gateway"
                    zDepth={0}>
                </AppBar>

                <AppLeftNav ref="leftNav" />
                <MenuButton onMenuButtonClick={this._onMenuIconButtonTouchTap}/>
                <PageWithNav menuItems={menuItems}/>

                {
                    this.state.authenticated ? null  : <LoginPage />
                }

            </AppCanvas>
        );
    }


});

module.exports = Master;