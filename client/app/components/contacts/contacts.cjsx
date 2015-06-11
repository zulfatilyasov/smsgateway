React = require 'react'
Router = require 'react-router'
mui = require 'material-ui'
contactStore = require '../../stores/ContactStore.coffee'
contactActions = require '../../actions/ContactActions.coffee'
userStore = require '../../stores/UserStore.coffee'
messageStore = require '../../stores/MessageStore.es6'
uiEvents = require '../../uiEvents.coffee'
{Dialog, Paper, MenuItem, Checkbox, IconButton, FlatButton} = mui
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'
ContactForm = require './contact-form.cjsx'
SearchBar = require '../search/searchbar.cjsx'
Filter = require '../contacts/filter.cjsx'
NewMessageForm = require '../messages/message-form.jsx'
PageWithNav = require '../page-with-nav/page-with-nav.jsx'
headerEvents = require('../../headerEvents.coffee')
PageHeader = require('../page-with-nav/pageHeader.cjsx')
Groups = require '../groups/groups.cjsx'
ContactVariableForm = require './contact-variable-form.cjsx'
classBuilder = require 'classnames'
check = require '../../services/validators.coffee'

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
        variables:contactStore.origVariables()

    _getConfirmationActions: (submitClickHandler) ->
        submit: ->
            uiEvents.closeDialog()
            submitClickHandler();
        cancel: ->
            uiEvents.closeDialog()

    handleCreateField:(e)->
        @refs.dialog.show()

    handleDeleteGroupContactsCheckbox:(e, value)->
        @deleteContacts = value

    _confirmGroupDeletion: (submitAction) ->
        actions = @_getConfirmationActions(submitAction)
        uiEvents.showDialog
          title:"Confirm Group Delete"
          text:<div className="delete-contacts"><div className="message">Delete all contacts that belong to this group only?</div> <Checkbox onCheck={@handleDeleteGroupContactsCheckbox} /></div>
          submitHandler:actions.submit
          cancelHandler:actions.cancel

    deleteGroup: (groupId) ->
        self = @
        @_confirmGroupDeletion ->
            userId = userStore.userId()
            contactActions.deleteGroup userId, groupId, self.deleteContacts

    handleContactFormChange:(e)->
        @formHeight = -1 * ($('.form').height() + 10)
        @filterFormHeight = -1 * ($('.searchForm').height() + 10)

    componentDidUpdate: (prevProps, prevState) ->
        self = @
        @formHeight = -1 * ($('.form').height() + 10)
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
        messageStore.addChangeListener @onChange
        uiEvents.addShowAddFieldDialog @onShowDialog
        @formHeight = -1 * $('.form').height()
        userId = userStore.userId();
        if userStore.isAuthenticated()
            contactActions.getUserVariables(userId);
        else
            userActions.logout()

    componentWillUnmount: ->
        headerEvents.removeChangeListener @onHeaderChange
        contactStore.removeChangeListener @onChange
        messageStore.removeChangeListener @onChange
        uiEvents.removeShowAddFieldDialog @onShowDialog

    onShowDialog:(position)->
        @hotCurrentRow = position.row
        @hotCurrentCol = position.col
        @refs.dialog.show() 

    onChange: ->
        isImport = _.includes @context.router.getCurrentPath(), 'contacts/import'
        state = 
            menuItems: contactStore.groupRouteList()
            showImportActions:isImport
            savingMessage:messageStore.IsSending
            isFiltering: contactStore.isFiltering()
            variables:contactStore.origVariables()

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

        if messageStore.IsSending
            @setState readyToCloseMessageForm: true
        else
            if @state.readyToCloseMessageForm
                @setState
                    showNewMessageForm:false
                    readyToCloseMessageForm:false
            else
                @setState readyToCloseMessageForm: false

        if contactStore.isFiltering()
            @setState readyToCloseSearchForm: true
        else
            if @state.readyToCloseSearchForm
                @setState
                    showSearchForm:false
                    readyToCloseSearchForm:false
            else
                @setState readyToCloseSearchForm: false

        @setState state

    onHeaderChange: (header) ->
        @setState header:header

    searchContacts: (query)->
        contactActions.searchContacts(query)
    
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

    closeErrorDialog:->
        @refs.errorDialog.dismiss()

    isValidPhone:(phone, rowIndex) ->
        if not check.isValidPhone(phone)
            @setState dialogMessage:"Phone is not valid. Aborting import.\nCheck row: #{rowIndex}"
            @refs.errorDialog.show()
            return false
        else 
            return true

    hasEmailOrPhone: (contact, rowIndex)->
        if not contact.phone and not contact.email
            @setState dialogMessage:"Contact should have Phone or Email. Aborting import. \n check row: #{rowIndex}"
            @refs.errorDialog.show()
            return false
        else 
            return true

    isValidEmail:(email, rowIndex) ->
        if not check.isValidEmail(email)
            @setState dialogMessage:"Email is not valid. Aborting import.\nCheck row: #{rowIndex}"
            @refs.errorDialog.show()
            return false
        else 
            return true

    valueMatchesType:(value, type, rowIndex) ->
        if type is 'date' and value and not check.isValidDate(value)
            @setState dialogMessage:"Invalid date. Aborting import.\nCheck row: #{rowIndex}"
            @refs.errorDialog.show()
            return false
        return true

    parseValue:(value, type)->
        if type is 'date'
            return null unless value
            return new Date(value)
        if type is 'boolean'
            if not value or value is 'false' or value is '0' or value is ''
                return false
            else
                return Boolean(value)
        if type is 'text' 
            return value.toString()
        return value

    handleImportContacts:(e) ->
        data = window.hot.getData()
        headers = data[0]
        contacts =[]
        userId = userStore.userId()

        for row, index in data
            if index isnt 0 and index isnt data.length - 1
                contact = 
                    userId:userId
                    vars:[]

                for cellValue, j in row
                    header = headers[j]
                    continue unless header
                    lowerHeader = header.toLowerCase()

                    if lowerHeader is 'name'
                        contact.name = cellValue
                        continue
                    if lowerHeader is 'phone'
                        if cellValue and not @isValidPhone(cellValue, index)
                            return
                        contact.phone = cellValue
                        continue
                    if lowerHeader is 'email'
                        if cellValue and not @isValidEmail(cellValue, index)
                            return
                        contact.email = cellValue 
                        continue

                    v = @getVariableByName(lowerHeader, j)
                    return unless v
                    if not @valueMatchesType(cellValue, v.type, index)
                        return
                    contact.vars.push
                        name:v.name
                        type:v.type
                        code:v.code
                        value:@parseValue(cellValue, v.type)

                if not @hasEmailOrPhone(contact, index)
                    return

                if not contact.name
                    contact.name = if contact.phone then contact.phone else contact.email

                contacts.push contact

        if contacts and contacts.length
            contactGroups = _.map window.groups, (g) ->
                name: g.label
                userId: userId
                id: if g.value is g.label then null else g.value
            @setState
                infoMessage: 'Saving contacts...'
            contactActions.importContacts(contacts, contactGroups, userId)

    getVariableByName:(varName, colIndex) ->
        variable = _.first(_.filter(@state.variables, (v) ->  return v.name.toLowerCase() is varName))
        if not variable
            @setState dialogMessage:"Unrecognised Column Header. Create new header by clicking \"Create Header\" button. \n Check column: #{colIndex + 1}"
            @refs.errorDialog.show()
        return variable

    handleFileInputChange:(e)->
        files = $('input#csvFile')[0].files
        return unless files?.length
        Papa.parse files[0],
            error: (err, file, inputElem, reason) ->
            complete: (result) ->
                window.hot.loadData(result.data)

    dialogCancelHandler:(e) ->
        @refs.dialog.dismiss()

    cancelNewMessageClickHandler:(e) ->
        @setState
            showNewMessageForm: false

    dialogSubmitHandler:(e)->
        newVariable = @refs.form.getNewVariable()
        return unless newVariable
        contactActions.createContactVariable newVariable
        if hot
            setTimeout =>
                hot.setDataAtCell @hotCurrentRow, @hotCurrentCol, newVariable.name
            , 700
        @refs.dialog.dismiss()

    getSelecetedIndex: () ->
        currentParams = @context.router.getCurrentParams()
        return i for menuItem, i in @state.menuItems when currentParams.groupId is menuItem.params?.groupId

    handleSendMessage:(e)->
        @setState
            addressList:contactStore.getSelectedConactOptions()
            showNewMessageForm: true

    render: ->
        formClasses = classBuilder
            form:true
            open:@state.showForm

        newMessageFormStyles =
            transform: if @state.showNewMessageForm then "translate(0px, 0px)" else "translate(0px, #{@formHeight}px)"

        filterFormStyles =
            transform: if @state.showSearchForm then "translate(0px, 0px)" else "translate(0px, #{@filterFormHeight}px)"

        searchFormClasses = classBuilder
            searchForm:true
            filterForm:true
            open:@state.showSearchForm

        groupsFormCasses = classBuilder
            groupsForm:true
            open:@state.showGroupForm

        newMessageFormClass = classBuilder
            form:true
            open:@state.showNewMessageForm

        dialogActions = [
          <FlatButton
            label="Add"
            key="add"
            primary={true}
            onTouchTap={@dialogSubmitHandler} />,

          <FlatButton
            label="Cancel"
            secondary={true}
            key="cancel"
            onTouchTap={@dialogCancelHandler} />
        ]

        formStyles =
            transform: if @state.showForm then "translate(0px, 0px)" else "translate(0px, #{@formHeight}px)"

        ok = [
          <FlatButton
            label="Ok"
            key="ok"
            primary={true}
            onTouchTap={@closeErrorDialog} />
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
                                            onChange={@handleFileInputChange}
                                            type="file"
                                            className="file-input"
                                            id="csvFile"/>
                                    </FlatButton>
                                    <FlatButton onClick={@handleCreateField} className="create" label="Create header" secondary={true} />
                                </div>
                            </div>
                        else
                          <div className="actions">
                            <Checkbox ref="checkbox" onCheck={@handleSelectAll} value="1"/>
                            <IconButton tooltip="Add to Group" onClick={@handleAddToGroup} iconClassName="icon-person-add" />
                            <IconButton tooltip="import" onClick={@handleImport} iconClassName="icon-cloud-upload" />
                            <IconButton tooltip="send message" onClick={@handleSendMessage} iconClassName="icon-paperplane" />
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
                    <div style={newMessageFormStyles} className={newMessageFormClass}>
                      <div className="form-content">
                        <NewMessageForm value={@state.addressList} cancelClickHandler={@cancelNewMessageClickHandler}/>
                      </div>
                    </div>
                    <div className={groupsFormCasses}>
                      <div className="form-content">
                        <Groups closeClickHandler={@cancelClickHandler} />
                      </div>
                    </div>
                    <div style={filterFormStyles} className={searchFormClasses}>
                      <div className="form-content">
                        {
                            if @state.showSearchForm
                                <Filter isFiltering={@state.isFiltering} closeClickHandler={@cancelClickHandler}/>
                        }
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
            <Dialog
                title="Validation Error"
                ref="errorDialog"
                actions={ok}>
                {@state.dialogMessage}
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