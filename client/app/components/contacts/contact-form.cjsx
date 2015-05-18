React = require('react')
contactStore = require '../../stores/ContactStore.coffee'
contactActions = require '../../actions/ContactActions.coffee'
userStore = require '../../stores/UserStore.coffee'
{RaisedButton, TextField} = require 'material-ui'
Select = require('react-select')

ContactForm = React.createClass
  
  getInitialState: ->
    saving: contactStore.isSaving()
    groups: contactStore.groupOptions()
    nameKey: 'name'
    nameValue: ''
    phoneKey: 'phone'
    phoneValue: ''
    groupKey: 'group'
    groupValue: ''
  
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
      phone:@phone
      userId:userId
      email:@email
      groups:contactGroups

    contactActions.saveContact(contact)

  handleNameChange: (e) ->
    @name = e.target.value

  handlePhoneChange: (e) ->
    @phone = e.target.value

  handleEmailChange: (e) ->
    @email = e.target.value

  onChange: ->
    state =
      saving:contactStore.isSaving()
      groups: contactStore.groupOptions()

    editedContact = contactStore.editedContact

    if editedContact
      state.nameKey = editedContact.name
      state.nameValue = editedContact.name
      state.phoneKey = editedContact.phone
      state.phoneValue = editedContact.phone
      state.groupKey = editedContact.group
      state.groupValue- editedContact.group
      @name = editedContact.name
      @phone = editedContact.phone
      @group = editedContact.group

    @setState state

  groupChanged:(val, values) ->
    @groups = values

  render: ->
    primaryButtonLabel = if @state.saving then 'Saving..' else 'Save'
    className = if @state.saving then 'saving' else ''
    saveButtonClass = 'saveButton ' + className
    <div className="contact-form pad">
        <div className="formInner">
            <div className="inputs">
              <TextField
                  key={@state.nameKey}
                  hintText="Enter contact name"
                  defaultValue={@state.nameValue}
                  className="input nameInput"
                  onChange={@handleNameChange}
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
                    options={@state.groups}
                    allowCreate={true}
                    placeholder="Groups"
                    onChange={@groupChanged} />
                <hr className="mui-text-field-focus-underline" />
              </div>
            </div>

            <div className="button-wrap">
                <div className="buttons">
                    <RaisedButton className={saveButtonClass}
                                  primary={true}
                                  disabled={@state.saving}
                                  onClick={@handleSaveContact}
                                  linkButton={true}
                                  label={primaryButtonLabel} >
                    </RaisedButton>

                    <RaisedButton className="cancel-button" onClick={@props.cancelClickHandler} linkButton={true}>
                        <span className="mui-raised-button-label">Cancel</span>
                    </RaisedButton>
                </div>
            </div>
        </div>
    </div>

module.exports = ContactForm