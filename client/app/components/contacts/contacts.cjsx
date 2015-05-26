React = require 'react'
Router = require 'react-router'
mui = require 'material-ui'
contactStore = require '../../stores/ContactStore.coffee'
contactActions = require '../../actions/ContactActions.coffee'
userStore = require '../../stores/UserStore.coffee'
uiEvents = require '../../uiEvents.coffee'
{Dialog, Paper, MenuItem, Checkbox, IconButton, FlatButton} = mui
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'
ContactForm = require './contact-form.cjsx'
SearchBar = require '../search/searchbar.cjsx'
PageWithNav = require '../page-with-nav/page-with-nav.jsx'
headerEvents = require('../../headerEvents.coffee')
PageHeader = require('../page-with-nav/pageHeader.cjsx')
Groups = require '../groups/groups.cjsx'
ContactVariableForm = require './contact-variable-form.cjsx'
classBuilder = require 'classnames'

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
        isImport = _.includes @context.router.getCurrentPath(), 'contacts/import'
        header: if isImport then 'Import Contacts' else 'Contacts'
        showForm: false
        showImportActions:isImport
        menuItems: contactStore.groupRouteList()

    _getConfirmationActions: (submitClickHandler) ->
        submit: ->
            uiEvents.closeDialog()
            submitClickHandler();
        cancel: ->
            uiEvents.closeDialog()

    handleCreateField:(e)->
        @refs.dialog.show()

    _confirmGroupDeletion: (submitAction) ->
        actions = @_getConfirmationActions(submitAction)
        uiEvents.showDialog
          title:"Confirm Delete"
          text:"Delete group permanently?"
          submitHandler:actions.submit
          cancelHandler:actions.cancel

    deleteGroup: (groupId) ->
        @_confirmGroupDeletion ->
            userId = userStore.userId()
            contactActions.deleteGroup userId, groupId

    handleContactFormChange:(e)->
        @formHeight = -1 * $('.form').height()

    componentDidUpdate: (prevProps, prevState) ->
        self = @
        @formHeight = -1 * $('.form').height()
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
        userId = userStore.userId();
        if userStore.isAuthenticated()
            contactActions.getUserVariables(userId);
        else
            userActions.logout()

    componentWillUnmount: ->
        headerEvents.removeChangeListener @onHeaderChange
        contactStore.removeChangeListener @onChange

    onChange: ->
        isImport = _.includes @context.router.getCurrentPath(), 'contacts/import'
        state = 
            menuItems: contactStore.groupRouteList()
            showImportActions:isImport
        if isImport
            state.header = 'Import Contacts' 

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

    handleImport:(e)->
       @context.router.transitionTo('importContacts')

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

    handleImportContacts:(e) ->
        data = window.hot.getData()
        console.log data
        headers = data[0]
        headers = _.map headers, (h) -> return h.toLowerCase()
        nameIndex = _.indexOf headers, 'name'
        phoneIndex = _.indexOf headers, 'phone'
        emailIndex = _.indexOf headers, 'email'
        contacts =[]
        userId = userStore.userId()

        for row, index in data
            if index isnt 0 and index isnt data.length - 1
                contact = {}
                if nameIndex >= 0
                    contact.name = row[nameIndex]
                if phoneIndex >= 0
                    contact.phone = row[phoneIndex]
                if emailIndex >= 0
                    contact.email = row[emailIndex] 
                contact.userId = userId
                contacts.push contact

        console.log contacts

    dialogCancelHandler:(e) ->
        @refs.dialog.dismiss()

    dialogSubmitHandler:(e)->
        newVariable = @refs.form.getNewVariable()
        return unless newVariable
        contactActions.createContactVariable newVariable
        @refs.dialog.dismiss()

    getSelecetedIndex: () ->
        currentParams = @context.router.getCurrentParams()
        return i for menuItem, i in @state.menuItems when currentParams.groupId is menuItem.params?.groupId

    render: ->
        formClasses = classBuilder
            form:true
            open:@state.showForm

        formStyles =
            transform: if @state.showForm then "translate(0px, 0px)" else "translate(0px, #{@formHeight}px)"

        searchFormClasses = classBuilder
            searchForm:true
            open:@state.showSearchForm

        groupsFormCasses = classBuilder
            groupsForm:true
            open:@state.showGroupForm

        dialogActions = [
          <FlatButton
            label="Add"
            key="ok"
            primary={true}
            onTouchTap={@dialogSubmitHandler} />,

          <FlatButton
            label="Cancel"
            secondary={true}
            key="cancel"
            onTouchTap={@dialogCancelHandler} />
        ]


        toolbar = <div className="toolbar">
                    <div className="toolbar-content">
                      <PageHeader key={@state.header} header={@state.header}/>
                      {
                        if @state.showImportActions
                            <div className="import-actions actions">
                                <div className="buttons">
                                    <FlatButton onClick={@handleImportContacts} className="create" label="Save Contacts" secondary={true} />
                                    <FlatButton className="create upload" secondary={true}>
                                        <span className="mui-flat-button-label upload-label">Upload csv</span>
                                        <input
                                            type="file"
                                            className="file-input"
                                            id="imageButton"/>
                                    </FlatButton>
                                    <FlatButton onClick={@handleCreateField} className="create" label="Create header" secondary={true} />
                                </div>
                            </div>
                        else
                          <div className="actions">
                            <Checkbox ref="checkbox" onCheck={@handleSelectAll} value="1"/>
                            <IconButton tooltip="Add to Group" onClick={@handleAddToGroup} iconClassName="icon-person-add" />
                            <IconButton tooltip="import" onClick={@handleImport} iconClassName="icon-cloud-upload" />
                            <IconButton tooltip="Delete" onClick={@handleDelete} iconClassName="icon-delete" />
                            <IconButton onClick={@handleSearchClick} tooltip="Search" iconClassName="icon-search" />
                            <div className="buttons">
                              <FlatButton onClick={@handleCreateContactClick} className="create" label="Create Contact" secondary={true} />
                            </div>
                          </div>
                      }
                    </div>
                    <div style={formStyles} className={formClasses}>
                      <div className="form-content">
                        <ContactForm onChange={@handleContactFormChange} cancelClickHandler={@cancelClickHandler}/>
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

        <div className="contacts">
            <Dialog
                title="Add Custom Field"
                className="custom-field-dialog"
                ref="dialog"
                actions={dialogActions}>
                    <ContactVariableForm ref="form"/>
            </Dialog>

            <Paper zDepth={1}>
                <div className="section">
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
        </div>

module.exports = Contacts