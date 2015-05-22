React = require 'react'
Router = require 'react-router'
mui = require 'material-ui'
contactStore = require '../../stores/ContactStore.coffee'
contactActions = require '../../actions/ContactActions.coffee'
userStore = require '../../stores/UserStore.coffee'
uiEvents = require '../../uiEvents.coffee'
{Paper, MenuItem, Checkbox, IconButton, FlatButton} = mui
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'
ContactForm = require './contact-form.cjsx'
SearchBar = require '../search/searchbar.cjsx'
PageWithNav = require '../page-with-nav/page-with-nav.jsx'
headerEvents = require('../../headerEvents.coffee')
PageHeader = require('../page-with-nav/pageHeader.cjsx')
Groups = require '../groups/groups.cjsx'
classBuilder = require 'classnames'
ramjet = require 'ramjet'

Contacts = React.createClass
    mixins: [Router.State]

    onItemClick: (item)->
        userId  = userStore.userId()
        if item.params?.groupId
            headerEvents.emitChange(item.text)
            contactActions.getUserContacts(userId, item.params.groupId)
        else
            headerEvents.emitChange('All Contacts')
            contactActions.getUserContacts(userId)

    getInitialState: ->
        header: 'Contacts'
        showForm: false
        menuItems: contactStore.groupRouteList()

    _getConfirmationActions: (submitClickHandler) ->
        submit: ->
            uiEvents.closeDialog()
            submitClickHandler();
        cancel: ->
            uiEvents.closeDialog()

    _confirmGroupDeletion: (submitAction) ->
        actions = @_getConfirmationActions(submitAction)
        uiEvents.showDialog
          title:"Confirm Delete"
          text: "Delete group permanently?"
          submitHandler:actions.submit
          cancelHandler:actions.cancel

    deleteGroup: (groupId) ->
        @_confirmGroupDeletion ->
            userId = userStore.userId()
            contactActions.deleteGroup userId, groupId


    componentDidUpdate: (prevProps, prevState) ->
        self = @
        $('.contacts .secondary-nav .mui-menu-item .mui-menu-item-icon')
            .each ->
                if not $(@).is('.listening') and $(@).length
                    $(@)[0].addEventListener "click", (event) ->
                        event.stopPropagation()
                        groupId = $(@).parent().find('.mui-menu-item-data').text()
                        self.deleteGroup(groupId)
                    $(@).addClass('listening')
    
    componentDidMount: ->
        headerEvents.addChangeListener @onHeaderChange
        contactStore.addChangeListener @onChange

    componentWillUnmount: ->
        headerEvents.removeChangeListener @onHeaderChange
        contactStore.removeChangeListener @onChange

    onChange: ->
        state = 
            menuItems: contactStore.groupRouteList()

        if contactStore.editedContact() and not @state.showForm
            state.showForm = true

        if contactStore.isSaving()
            state.readyToClose = true
        else
            if @state.readyToClose
                state.showForm = false
            state.readyToClose = false

        @setState state

    onHeaderChange: (header) ->
        @setState header:header
    
    handleCreateContactClick: ->
        @setState showForm:true

    _getConfirmationActions: (submitClickHandler) ->
        submit: ->
            uiEvents.closeDialog()
            submitClickHandler();
        cancel: ->
            uiEvents.closeDialog()

    _confirmDeletion: (submitAction) ->
        if contactStore.selectedContacts().length
            actions = @_getConfirmationActions(submitAction)
            uiEvents.showDialog
              title: "Confirm Delete"
              text: "Delete selected contacts permanently?"
              submitHandler:actions.submit
              cancelHandler:actions.cancel

    handleDelete: (e) ->
        e.preventDefault()
        selectedIds = contactStore.selectedContactIds()
        @_confirmDeletion ->
          contactActions.deleteContacts selectedIds
        return

    handleCancelContacts: (e) ->
        e.preventDefault()
        userId = userStore.userId()
        selectedIds = contactStore.selectedContactIds()
        contactActions.cancelContacts selectedIds, userId
        return

    cancelClickHandler: ->
        @setState
            showForm:false
            showSearchForm:false
            showGroupForm:false
        contactActions.clearEdit()

    handleSearchClick: ->
        @setState showSearchForm:true

    handleAddToGroup: ->
        if contactStore.selectedContacts().length
            @setState showGroupForm:true
            contactActions.aggregateGroups()

    handleSelectAll: ->
        isChecked = @refs.checkbox.isChecked()
        contactActions.selectAllItems isChecked

    getSelecetedIndex: () ->
        currentParams = @context.router.getCurrentParams()
        return i for menuItem, i in @state.menuItems when currentParams.groupId is menuItem.params?.groupId

    render: ->
        formClasses = classBuilder
            form:true
            open:@state.showForm

        searchFormClasses = classBuilder
            searchForm:true
            open:@state.showSearchForm

        groupsFormCasses = classBuilder
            groupsForm:true
            open:@state.showGroupForm

        toolbar = <div className="toolbar">
                    <div className="toolbar-content">
                      <PageHeader key={@state.header} header={@state.header}/>
                      <div className="actions">
                        <Checkbox ref="checkbox" onCheck={@handleSelectAll} value="1"/>
                        <IconButton tooltip="Add to Group" onClick={@handleAddToGroup} iconClassName="icon-person-add" />
                        <IconButton tooltip="import" onClick={@handleImport} iconClassName="icon-cloud-upload" />
                        <IconButton tooltip="Delete" onClick={@handleDelete} iconClassName="icon-delete" />
                        <IconButton onClick={@handleSearchClick} tooltip="Search" iconClassName="icon-search" />
                        <div className="buttons">
                          <div className="ramjetA"></div>
                          <FlatButton onClick={@handleCreateContactClick} className="create" label="Create Contact" secondary={true} />
                        </div>
                      </div>
                    </div>
                    <div className={formClasses}>
                      <div className="form-content">
                        <ContactForm cancelClickHandler={@cancelClickHandler}/>
                      </div>
                    </div>
                    <div className={groupsFormCasses}>
                      <div className="form-content">
                        <Groups closeClickHandler={@cancelClickHandler} />
                      </div>
                    </div>
                    <div className={searchFormClasses}>
                      <div className="form-content">
                        <SearchBar closeClickHandler={@cancelClickHandler} />
                      </div>
                    </div>
                  </div>

        <Paper zDepth={1}>
            <div className="section contacts">
                <div className="section-header">
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown">
                       <h2>Contacts</h2>  
                    </ReactCSSTransitionGroupAppear>
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown2">
                       <h4>Manage contacts and groups</h4>
                    </ReactCSSTransitionGroupAppear>
                </div>

                <div className="section-body">
                    <PageWithNav toolbar={toolbar} selectedIndex={@getSelecetedIndex} onMenuItemClick={@onItemClick} menuItems={@state.menuItems}/>
                </div>
            </div>
        </Paper>

module.exports = Contacts