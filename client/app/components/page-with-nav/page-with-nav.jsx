var React = require('react'),
  Router = require('react-router'),
  RouteHandler = Router.RouteHandler,
  mui = require('material-ui'),
  classBuilder = require('classnames'),
  RaisedButton = mui.RaisedButton,
  FlatButton = mui.FlatButton,
  IconButton = mui.IconButton,
  Checkbox = mui.Checkbox,
  headerEvents = require('../../headerEvents.coffee'),
  uiEvents = require('../../uiEvents.coffee'),
  NewMessageForm = require('../messages/form-inner.jsx'),
  messageStore = require('../../stores/MessageStore.es6'),
  userStore = require('../../stores/UserStore.coffee'),
  messageActions = require('../../actions/MessageActions.coffee'),
  SearchBar = require('../../components/search/searchbar.cjsx'),
  PageHeader = require('./pageHeader.cjsx'),
  ReactCSSTransitionGroupAppear = require('../../react-helpers/ReactCSSTransitionAppear.jsx'),
  Menu = mui.Menu;



var PageWithNav = React.createClass({

  mixins: [Router.Navigation, Router.State],

  propTypes: {
    menuItems: React.PropTypes.array
  },

  componentWillMount: function() {
    messageStore.addChangeListener(this.onChange);
    headerEvents.addChangeListener(this.onHeaderChange);
  },

  componentWillUnmount: function() {
    messageStore.removeChangeListener(this.onChange);
    headerEvents.removeChangeListener(this.onHeaderChange);
  },

  onChange:function () {
    if(messageStore.IsSending){
      this.setState({readyToClose: true});
    }

    if(messageStore.MessageToResend && !this.state.showForm){
      this.setState({showForm:true});
    }

    if(!messageStore.IsSending) {
      if(this.state.readyToClose) {
        this.setState({showForm:false, readyToClose:false});
      }else{
        this.setState({readyToClose: false});
      }
    }
  },

  _getConfirmationActions(submitClickHandler){
    return {
        submit:function () {
            uiEvents.closeDialog();
            submitClickHandler(); 
        },
        cancel:function () {
            uiEvents.closeDialog();
        }
    };
  },

  _confirmDeletion(submitAction){
    var actions = this._getConfirmationActions(submitAction);
    uiEvents.showDialog({
      title:"Confirm Delete",
      text: "Delete selected messages permanently?",
      submitHandler:actions.submit,
      cancelHandler:actions.cancel
    });
  },

  _confirmResend(submitAction){
    var actions = this._getConfirmationActions(submitAction);
    uiEvents.showDialog({
      title:"Confirm Resend",
      text: "Resend selected messages?",
      submitHandler:actions.submit,
      cancelHandler:actions.cancel
    });
  },

  handleDelete:function (e) {
    e.preventDefault();
    var selectedIds = messageStore.selectedMessageIds();
    this._confirmDeletion(function () {
      messageActions.deleteMany(selectedIds);
    });
  },

  handleCancelMessages: function (e) {
    e.preventDefault();
    var userId = userStore.userId();
    var selectedIds = messageStore.selectedMessageIds();
    messageActions.cancelMessages(selectedIds, userId);
  },

  onHeaderChange:function(header){
    this.setState({header:header}) 
  },

  render: function() {
    var contentStyle = {minHeight:this.state.contentHeight}
    var formClasses = classBuilder({
      form:true,
      open:this.state.showForm
    });

    var searchFormClasses = classBuilder({
      searchForm:true,
      open:this.state.showSearchForm
    });

    return (
      <div className="page-with-nav">
        <div className="secondary-nav">
          <Menu 
            ref="menuItems" 
            zDepth={0} 
            autoWidth={false}
            menuItems={this.props.menuItems} 
            selectedIndex={this._getSelectedIndex()} 
            onItemTap={null}
            onItemClick={this._onMenuItemClick} />
        </div>
        <div style={contentStyle} className="secondary-content">
          <div className="toolbar">
            <div className="toolbar-content">
              <PageHeader key={this.state.header} header={this.state.header}/>
              <div className="actions">
                <Checkbox ref="checkbox" onCheck={this.handleSelectAll} value="1"/>
                <IconButton tooltip="Resend" onClick={this.handleResendClick} iconClassName="icon-repeat" />
                <IconButton tooltip="Delete" onClick={this.handleDelete} iconClassName="icon-delete" />
                <IconButton tooltip="Cancel" onClick={this.handleCancelMessages} iconClassName="icon-close" />
                <IconButton onClick={this.handleSearchClick} tooltip="Search" iconClassName="icon-search" />
                <div className="buttons">
                  <FlatButton onClick={this.handleCreateMessageClick} className="create-message" label="Create message" secondary={true} />
                </div>

              </div>
            </div>
            <div className={formClasses}>
              <div className="form-content">
                <NewMessageForm cancelClickHandler={this.cancelClickHandler}/>
              </div>
            </div>
            <div className={searchFormClasses}>
              <div className="form-content">
                <SearchBar closeClickHandler={this.cancelClickHandler} />
              </div>
            </div>
          </div>
          <RouteHandler />
        </div>
      </div>
    );
  },

  cancelClickHandler:function () {
    this.setState({
      showForm:false,
      showSearchForm:false
     });
    messageActions.clearResend();
  },

  handleSearchClick: function () {
    this.setState({showSearchForm:true});
  },

  handleSelectAll:function () {
    var isChecked = this.refs.checkbox.isChecked()
    messageActions.selectAllItems(isChecked);
  },

  handleResendClick:function (e) {
    e.preventDefault();
    var selectedIds = messageStore.selectedMessageIds();
    this._confirmResend(function () {
      messageActions.resend(selectedIds);
    });
  },

  handleCreateMessageClick: function () {
    this.setState({showForm:true});
  },

  _getSelectedIndex: function() {
    var menuItems = this.props.menuItems,
      currentItem;

    for (var i = menuItems.length - 1; i >= 0; i--) {
      currentItem = menuItems[i];
      if (currentItem.route && this.context.router.isActive(currentItem.route)) return i;
    };
  },

  getInitialState: function() {
    var pageHeaderHeight = 165;
    var viewportHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
    return {
      contentHeight: viewportHeight - pageHeaderHeight,
      header:'All messages'
    };
  },

  _onMenuItemClick: function(e, index, item) {
    e.preventDefault();
    if(item.route){
      this.context.router.transitionTo(item.route);
    }
    else{
      this.props.onMenuItemClick(item);
    }
  }
  
});

module.exports = PageWithNav;