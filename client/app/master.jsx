var React = require('react');
var Router = require('react-router');
var RouteHandler = Router.RouteHandler;
var mui, { FlatButton, Dialog, FloatingActionButton, AppBar, AppCanvas, FontIcon, Menu, IconButton, Snackbar } = require('material-ui');
var LoginPage = require('./components/login/login-page.cjsx');
var userStore = require('./stores/UserStore.coffee');
var contactActions = require('./actions/ContactActions.coffee');
var MenuButton = require('./components/menu-button/menu-button.jsx');
var AppLeftNav = require('./app-left-nav.jsx');
var messageActions = require('./actions/MessageActions.coffee');
var userActions = require('./actions/UserActions.coffee');
var uiEvents = require('./uiEvents.coffee');
var _ = require('lodash');
_.mixin(require("lodash-deep"));

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
        $('.menu-button').scrollToFixed({marginTop:40});
        if(this.state.authenticated){
            var userId  = userStore.userId();
            messageActions.startReceiving();
            userActions.startWatchingDevice();
            userActions.getUserDevice();
            contactActions.getUserGroups(userId);
            contactActions.getUserContacts(userId);
            contactActions.getAddressList();
        }

        this.setState({
            authenticated: userStore.isAuthenticated()
        });
        
        uiEvents.addShowDialogListener(this._composeDialog);
        uiEvents.addCloseDialogListener(this._closeDialog);
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
        uiEvents.removeShowDialogListener(this._composeDialog);
        uiEvents.removeCloseDialogListener(this._closeDialog);
        userStore.removeChangeListener(this._onChange);
    },

    _onChange() {
        if(this.isMounted()){
            console.log('called on changed master')
            this.setState(getState());
        }
    },

    _composeDialog(dialogContent){
        this.setState({
            dialogTitle: dialogContent.title,
            dialogText: dialogContent.text,
            dialogCancelHandler: dialogContent.cancelHandler,
            dialogSubmitHandler: dialogContent.submitHandler
        });
        this.refs.dialog.show();
    },

    _closeDialog(){
        this.refs.dialog.dismiss();
    },

    _onMenuIconButtonTouchTap() {
        this.refs.leftNav.toggle();
    },

    _hideSnake(){
        this.refs.snackbar.dismiss()
    },

    render() {
        var dialogActions = [
          <FlatButton
            label="Ok"
            key="ok"
            primary={true}
            onTouchTap={this.state.dialogSubmitHandler} />
        ];

        if(this.state.dialogCancelHandler){
            var cancelButton = <FlatButton
                                label="Cancel"
                                secondary={true}
                                key="cancel"
                                onTouchTap={this.state.dialogCancelHandler} />
            dialogActions.push(cancelButton);
        }

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


                <Dialog
                  title={this.state.dialogTitle}
                  ref="dialog"
                  modal={true}
                  actions={dialogActions}>
                  {this.state.dialogText}
                </Dialog>
            </AppCanvas>
        );
    }


});

module.exports = Master;