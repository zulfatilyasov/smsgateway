React = require 'react'
Router = require 'react-router'
mui = require 'material-ui'
messageStore = require '../../stores/MessageStore.es6'
messageActions = require '../../actions/MessageActions.coffee'
userStore = require '../../stores/UserStore.coffee'
uiEvents = require '../../uiEvents.coffee'
{Paper, MenuItem, Checkbox, IconButton, FlatButton} = mui
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'
NewMessageForm = require '../messages/message-form.jsx'
SearchBar = require '../search/searchbar.cjsx'
PageWithNav = require '../page-with-nav/page-with-nav.jsx'
headerEvents = require('../../headerEvents.coffee')
PageHeader = require('../page-with-nav/pageHeader.cjsx')
classBuilder = require 'classnames'

Messages = React.createClass
    mixins: [Router.State]

    onItemClick: (item)->
        if item.payload
            userId  = userStore.userId()
            messageActions.getUserMessages(userId, item.payload)

    getInitialState: ->
        header: 'All messages'
        showForm: false

    componentDidMount: ->
        headerEvents.addChangeListener @onHeaderChange
        messageStore.addChangeListener @onChange

    componentDidUpdate: (prevProps, prevState) ->
        @formHeight = -1 * $('.form').height()
    
    componentWillUnmount: ->
        headerEvents.removeChangeListener @onHeaderChange
        messageStore.removeChangeListener @onChange

    onChange: ->
        if messageStore.IsSending
            @setState readyToClose: true

        if messageStore.MessageToResend and not @state.showForm
            @setState showForm:true

        if not messageStore.IsSending
            debugger
            if @state.readyToClose
                @setState
                    showForm:false
                    readyToClose:false
            else
                @setState readyToClose: false

    onHeaderChange: (header) ->
        @setState header:header
    
    handleResendClick:(e) ->
        e.preventDefault()
        selectedIds = messageStore.selectedMessageIds()
        @_confirmResend ->
          messageActions.resend selectedIds
        return

    handleCreateMessageClick: ->
        @setState showForm:true

    _getConfirmationActions: (submitClickHandler) ->
        submit: ->
            uiEvents.closeDialog()
            submitClickHandler();
        cancel: ->
            uiEvents.closeDialog()

    _confirmDeletion: (submitAction) ->
        actions = @_getConfirmationActions(submitAction)
        uiEvents.showDialog
            title:"Confirm Delete"
            text: "Delete selected messages permanently?"
            submitHandler:actions.submit
            cancelHandler:actions.cancel

    _confirmResend: (submitAction) ->
        actions = @_getConfirmationActions(submitAction)
        uiEvents.showDialog
            title:"Confirm Resend"
            text: "Resend selected messages?"
            submitHandler:actions.submit
            cancelHandler:actions.cancel

    handleDelete: (e) ->
        e.preventDefault()
        selectedIds = messageStore.selectedMessageIds()
        @_confirmDeletion ->
          messageActions.deleteMany selectedIds
        return

    handleCancelMessages: (e) ->
        e.preventDefault()
        userId = userStore.userId()
        selectedIds = messageStore.selectedMessageIds()
        messageActions.cancelMessages selectedIds, userId
        return

    cancelClickHandler: ->
        @setState
            showForm:false
            showSearchForm:false
        messageActions.clearResend()

    handleSearchClick: ->
        @setState showSearchForm:true

    handleSelectAll: ->
        isChecked = @refs.checkbox.isChecked()
        messageActions.selectAllItems isChecked

    getSelectedIndex:() ->
        return i for menuItem, i in @menuItems when menuItem.route and @context.router.isActive(menuItem.route)

    render: ->
        @menuItems = [
            {route: 'allmessages', text: 'All messages',iconClassName:'icon icon-chat'}
            {route: 'outcoming', text: 'Outcoming', iconClassName:'icon icon-arrow-with-circle-left'}
            {route: 'incoming', text: 'Incoming',iconClassName:'icon icon-arrow-with-circle-right'}
            {route: 'starred', text: 'Starred',iconClassName:'icon icon-star'}
            {text: 'Status', iconClassName:'icon icon-star', type: MenuItem.Types.NESTED, items:[
                { payload: 'sent', text: 'Sent', iconClassName:'icon icon-arrow-with-circle-left' }
                { payload: 'queued', text: 'Queued', iconClassName:'icon icon-repeat'}
                { payload: 'cancelled', text: 'Cancelled', iconClassName:'icon icon-close' }
                { payload: 'failed', text: 'Failed', iconClassName:'icon icon-sms-failed' }
            ]}
        ]

        formClasses = classBuilder
            form:true
            open:@state.showForm

        formStyles =
            transform: if @state.showForm then "translate(0px, 0px)" else "translate(0px, #{@formHeight}px)"

        searchFormClasses = classBuilder
            searchForm:true
            open:@state.showSearchForm

        toolbar = <div className="toolbar">
                    <div className="toolbar-content">
                      <PageHeader key={@state.header} header={@state.header}/>
                      <div className="actions">
                        <Checkbox ref="checkbox" onCheck={@handleSelectAll} value="1"/>
                        <IconButton tooltip="Resend" onClick={@handleResendClick} iconClassName="icon-repeat" />
                        <IconButton tooltip="Delete" onClick={@handleDelete} iconClassName="icon-delete" />
                        <IconButton tooltip="Cancel" onClick={@handleCancelMessages} iconClassName="icon-close" />
                        <IconButton onClick={@handleSearchClick} tooltip="Search" iconClassName="icon-search" />
                        <div className="buttons">
                          <FlatButton onClick={@handleCreateMessageClick} className="create" label="Create message" secondary={true} />
                        </div>
                      </div>
                    </div>
                    <div style={formStyles} className={formClasses}>
                      <div className="form-content">
                        <NewMessageForm cancelClickHandler={@cancelClickHandler}/>
                      </div>
                    </div>
                    <div className={searchFormClasses}>
                      <div className="form-content">
                        <SearchBar closeClickHandler={@cancelClickHandler} />
                      </div>
                    </div>
                  </div>

        <Paper zDepth={1}>
            <div className="section">
                <div className="section-header">
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown">
                       <h2>Messages</h2>  
                    </ReactCSSTransitionGroupAppear>
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown2">
                       <h4>Search history or compose new message</h4>  
                    </ReactCSSTransitionGroupAppear>
                </div>

                <div className="section-body">
                    <PageWithNav selectedIndex={@getSelectedIndex} toolbar={toolbar} onMenuItemClick={@onItemClick} menuItems={@menuItems}/>
                </div>
            </div>
        </Paper>

module.exports = Messages