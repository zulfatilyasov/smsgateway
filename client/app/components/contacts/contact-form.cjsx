React = require('react')
contactStore = require '../../stores/ContactStore.coffee'
contactActions = require '../../actions/ContactActions.coffee'
userStore = require '../../stores/UserStore.coffee'
{DropDownMenu, Dialog, Checkbox, DatePicker, RaisedButton, FlatButton, TextField} = require 'material-ui'
Select = require('react-select')
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
      if not @newFieldName
        @setState fieldNameError:'field name is required'
        return 
      if not @state.newFieldCode
        @setState fieldCodeError:'field code is required'
        return 

      newVariable =
        name:@newFieldName
        userId:userStore.userId()
        type:@newFieldType || @state.fieldTypes[0].payload
        code:@state.newFieldCode

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
                  return <DatePicker
                    name={customField.name}
                    defaultDate={date}
                    onClick={@handleDateFieldClick}
                    onChange={@handleDateFieldChange}
                    key={customField.code + n}
                    hintText={customField.name} />

                if customField.type is 'boolean'
                  return <Checkbox
                    name={customField.name}
                    defaultSwitched={customField.value}
                    type='checkbox'
                    label={customField.name}
                    key={customField.code + n}
                    onCheck={@handleCustomFieldChange} />

                if customField.type is 'text'
                  return <TextField
                    name={customField.name}
                    type='text'
                    key={customField.code + n}
                    defaultValue={customField.value}
                    floatingLabelText={customField.name}
                    onChange={@handleCustomFieldChange}
                    className="input"/>
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
          ref="dialog"
          actions={dialogActions}>
          {
            if @state.createVariable
              <div>
                <TextField
                  onChange={@handleFieldNameChange}
                  errorText={@state.fieldNameError}
                  floatingLabelText="Field Name"/>

                <TextField
                  onChange={@handleFieldCodeChange}
                  errorText={@state.fieldCodeError}
                  value={@state.newFieldCode}
                  floatingLabelText="Field Code"/>

                <div className="field-type">
                  <label className="field-type-label">Field Type:</label>
                  <DropDownMenu onChange={@handleFieldTypeChange} menuItems={@state.fieldTypes} />
                </div>
              </div>
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