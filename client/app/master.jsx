var React = require('react');
var Router = require('react-router');
var RouteHandler = Router.RouteHandler;
var mui, {FloatingActionButton, AppBar, AppCanvas, FontIcon, Menu, IconButton, Snackbar } = require('material-ui');
var LoginPage = require('./components/login/login-page.cjsx');
var userStore = require('./stores/UserStore.coffee');
var MenuButton = require('./components/menu-button/menu-button.jsx');
var AppLeftNav = require('./app-left-nav.jsx');
var messageActions = require('./actions/MessageActions.coffee');
var userActions = require('./actions/UserActions.coffee');

var getState = function () {
    console.log(userStore.snackMessage());
    return {
        authenticated: userStore.isAuthenticated(),
        snackMessage: userStore.snackMessage()
    };
};

var Master = React.createClass({

    mixins: [Router.State],

    getInitialState(){
        return {
            authenticated: userStore.isAuthenticated(),
            snackMessage: userStore.snackMessage()
        };
    },

    componentDidMount() {
        if(this.state.authenticated){
            messageActions.startReceiving();
            userActions.startWatchingDevice();
            userActions.getUserDevice();
        }

        this.setState({
            authenticated: userStore.isAuthenticated()
        });
        
        userStore.addChangeListener(this._onChange);
    },

    componentDidUpdate: function(prevProps, prevState) {
        if(prevState.snackMessage !== this.state.snackMessage){
            var refs = this.refs;
            refs.snackbar.show();
            setTimeout(function () {
                refs.snackbar.dismiss();
            }, 5000)
        }
    },

    componentWillUnmount() {
        console.log('masterjsx will unmounted')
        userStore.removeChangeListener(this._onChange);
    },

    _onChange() {
        if(this.isMounted()){
            console.log('called on changed master')
            this.setState(getState());
        }
    },

    _onMenuIconButtonTouchTap() {
        this.refs.leftNav.toggle();
    },

    _hideSnake(){
        this.refs.snackbar.dismiss()
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

        return (
            <AppCanvas>
                <Snackbar
                    ref="snackbar"
                    action="ok"
                    message={this.state.snackMessage || ''}
                    onActionTouchTap={this._hideSnake}/>
                <AppBar
                    className="mui-dark-theme"
                    onMenuIconButtonTouchTap={this._onMenuIconButtonTouchTap}
                    showMenuIconButton={false}
                    title="SMS Gateway"
                    zDepth={0}>
                </AppBar>

                <AppLeftNav ref="leftNav" />
                <MenuButton onMenuButtonClick={this._onMenuIconButtonTouchTap}/>
                <div className="mui-app-content-canvas">
                    <RouteHandler />
                </div>
            </AppCanvas>
        );
    }


});

module.exports = Master;