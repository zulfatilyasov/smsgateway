React = require('react')
contactStore = require '../../stores/ContactStore.coffee'
contactActions = require '../../actions/ContactActions.coffee'
userStore = require '../../stores/UserStore.coffee'
{FontIcon, DropDownMenu, Dialog, Checkbox, DatePicker, RaisedButton, FlatButton, TextField} = require 'material-ui'
Select = require('react-select')
ContactVariableForm = require './contact-variable-form.cjsx'
_ = require 'lodash'

ContactForm = React.createClass
  
  getInitialState: ->
    variables = contactStore.variables()
    saving: contactStore.isSaving()
    groups: contactStore.groupOptions()
    nameKey: 'name'
    nameValue: ''
    emailKey:'email'
    emailValue:''
    phoneKey: 'phone'
    phoneValue: ''
    groupKey: 'group'
    groupValue: []
    vars:[]
    variables:variables
    createVariable: if variables.length then false else true
    fieldTypes: [
      { payload: 'text', text: 'Text' }
      { payload: 'date', text: 'Date' }
      { payload: 'boolean', text: 'CheckBox' }
    ]

  componentDidMount: ->
    contactStore.addChangeListener @onChange

  componentWillUnmount: ->
    contactStore.removeChangeListener @onChange

  handleSaveContact: ->
    userId = userStore.userId()
    contactGroups = _.map @groups, (g) ->
      name: g.label
      userId: userId
      id: if g.value is g.label then null else g.value

    contact = 
      name:@name
      id:@id
      phone:@phone
      userId:userId
      email:@email
      vars:@state.vars
      groups:contactGroups

    @creatingContact = false
    contactActions.saveContact(contact)

  handleNameChange: (e) ->
    @name = e.target.value

  handlePhoneChange: (e) ->
    @phone = e.target.value

  handleEmailChange: (e) ->
    @email = e.target.value

  handleFieldCodeChange: (e) ->
    @setState
      newFieldCode: e.target.value

  handleFieldNameChange: (e) ->
    @newFieldName = e.target.value
    if not @newFieldName.length
      return
    fieldCode = @newFieldName.toLowerCase().replace(/ /g, '-')
    @setState
      newFieldCode: fieldCode

  handleFieldTypeChange: (e, index, item) ->
    @newFieldType = item.payload

  handleCustomFieldChange:(e) ->
    customField = _.first _.filter(@state.vars, name:e.target.name)
    if e.target.type is 'checkbox'
      customField.value = e.target.checked
    if e.target.type is 'text'
      customField.value = e.target.value

  handleDateFieldClick:(e)->
    @activeDateFieldName = e.target.name

  handleVarSelected:(e, selectedIndex, item)->
    @selectedVariable = item.payload

  dialogSubmitHandler:(e)->
    vars = @state.vars
    if @state.createVariable
      newVariable = @refs.form.getNewVariable()
      return unless newVariable
      vars.push(newVariable)
      contactActions.createContactVariable newVariable
    else
      selectedVar = if @selectedVariable then _.cloneDeep(@selectedVariable) else _.cloneDeep(@state.variables[0].payload)
      vars.push(selectedVar)

    @setState
      vars:vars

    @refs.dialog.dismiss()

  componentDidUpdate: (prevProps, prevState) ->
    @props.onChange()

  dialogCancelHandler:(e) ->
    @refs.dialog.dismiss()

  handleDateFieldChange:(e, value)->
    customField = _.first _.filter(@state.vars, name:@activeDateFieldName)
    customField.value = value;

  handleAddField:(e) ->
    @refs.dialog.show()

  handleFormCancel:(e) ->
    if @creatingContact
      @setState
        vars:[]
    @props.cancelClickHandler()

  dialogCreateNewHandler:(e) ->
    @selectedVariable = null
    @setState
      createVariable:true

  onChange: ->
    variables = contactStore.variables()
    state =
      saving:contactStore.isSaving()
      groups:contactStore.groupOptions()
      variables:variables
      createVariable: if variables.length then false else true

    editedContact = contactStore.editedContact()

    if editedContact and @id isnt editedContact.id
      state.nameKey = editedContact.name + 'NAME'
      state.nameValue = editedContact.name
      state.phoneKey = editedContact.phone + 'PHONE'
      state.phoneValue = editedContact.phone
      state.emailKey = editedContact.email + 'EMAIL'
      state.emailValue = editedContact.email
      state.groupValue = editedContact.groups
      state.vars = if editedContact.vars then _.cloneDeep(editedContact.vars) else []
      @id = editedContact.id
      @name = editedContact.nameKey
      @phone = editedContact.phone
      @groups = editedContact.groups
      @creatingContact = false

    if editedContact is null and not @creatingContact
      state.nameKey = _.now() + 'NAME'
      state.nameValue = ''
      state.phoneKey = _.now() + 'PHONE'
      state.phoneValue = ''
      state.emailKey = _.now() + 'EMAIL'
      state.emailValue = ''
      state.groupValue = null
      state.vars = []
      @creatingContact = true
      @id = null
      @name = ''
      @phone = ''
      @groups = ''

    @setState state

  groupChanged:(val, values) ->
    @groups = values
    @setState
      groupValue: @groups

  handleDeleteVar:(e)->
    varCode = e.target.children.namedItem('code').innerText
    vars = @state.vars
    _.remove vars, {code:varCode}
    @setState vars:vars

  render: ->
    primaryButtonLabel = if @state.saving then 'Saving..' else 'Save'
    className = if @state.saving then 'saving' else ''
    saveButtonClass = 'button saveButton ' + className
      
    dialogActions = [
      <FlatButton
        label="Add"
        key="ok"
        primary={true}
        onTouchTap={@dialogSubmitHandler} />,
    ]
    if not @state.createVariable
      dialogActions.push(
        <FlatButton
          label="Create new"
          secondary={true}
          key="create"
          onTouchTap={@dialogCreateNewHandler} />)

    dialogActions.push(
      <FlatButton
        label="Cancel"
        secondary={true}
        key="cancel"
        onTouchTap={@dialogCancelHandler} />)

    <div className="contact-form pad">
      <div className="formInner">
        <div className="inputs">
          <TextField
            key={@state.nameKey}
            hintText="Enter contact name"
            defaultValue={@state.nameValue}
            className="input nameInput"
            onChange={@handleNameChange }
            floatingLabelText="Name"/>

          <TextField
            hintText="Enter contact phone"
            floatingLabelText="Phone"
            key={@state.phoneKey}
            defaultValue={@state.phoneValue}
            onChange={@handlePhoneChange}
            className="input phoneInput"/>

          <TextField
            hintText="Enter contact email"
            floatingLabelText="Email"
            key={@state.emailKey}
            defaultValue={@state.emailValue}
            onChange={@handleEmailChange}
            className="input emailInput"/>

          <div className="group">
            <Select
              multi={true}
              value={@state.groupValue}
              options={@state.groups}
              allowCreate={true}
              placeholder="Groups"
              onChange={@groupChanged} />
          </div>
          {
            if @state.vars?.length
              _.map @state.vars, (customField, n) =>
                if customField.type is 'date'
                  date = if customField.value then new Date(customField.value) else null
                  return <div key={customField.code + n} className="varInput">
                          <DatePicker
                            name={customField.name}
                            className="var"
                            defaultDate={date}
                            onClick={@handleDateFieldClick}
                            onChange={@handleDateFieldChange}
                            hintText={customField.name} />
                          <FontIcon onClick={@handleDeleteVar} className="icon icon-close">
                            <span className="hidden" name="code">{customField.code}</span>
                          </FontIcon>
                        </div>

                if customField.type is 'boolean'
                  return <div key={customField.code + n} className="varInput">
                          <Checkbox
                            name={customField.name}
                            defaultSwitched={customField.value}
                            className="var"
                            type='checkbox'
                            label={customField.name}
                            onCheck={@handleCustomFieldChange} />
                          <FontIcon onClick={@handleDeleteVar} className="icon icon-close">
                            <span className="hidden" name="code">{customField.code}</span>
                          </FontIcon>
                        </div>

                if customField.type is 'text'
                  return <div  key={customField.code + n} className="varInput">
                          <TextField
                            name={customField.name}
                            type='text'
                            defaultValue={customField.value}
                            floatingLabelText={customField.name}
                            onChange={@handleCustomFieldChange}
                            className="var input"/>                
                          <FontIcon onClick={@handleDeleteVar} className="icon icon-close">
                            <span className="hidden" name="code">{customField.code}</span>
                          </FontIcon>
                        </div>
          }

        </div>

        <div className="button-wrap">
            <div className="buttons">
              <FlatButton 
                label="Add Field"
                secondary={true}
                className="button add-field-button"
                onClick={@handleAddField}>
              </FlatButton>

              <RaisedButton
                className={saveButtonClass}
                primary={true}
                disabled={@state.saving}
                onClick={@handleSaveContact}
                linkButton={true}
                label={primaryButtonLabel} >
              </RaisedButton>

              <RaisedButton
                className="button cancel-button"
                onClick={@handleFormCancel}
                linkButton={true}>
                  <span className="mui-raised-button-label">Cancel</span>
              </RaisedButton>
            </div>
        </div>
        <Dialog
          title="Add Custom Field"
          className="custom-field-dialog"
          ref="dialog"
          actions={dialogActions}>
          {
            if @state.createVariable
              <ContactVariableForm ref="form"/>
            else
                <div>
                  <div>
                    Please select custom field
                  </div>
                  <DropDownMenu key={@state.variables.length + 'variables'} onChange={@handleVarSelected} menuItems={@state.variables} />
                </div>

          }
        </Dialog>
      </div>
    </div>

module.exports = ContactForm