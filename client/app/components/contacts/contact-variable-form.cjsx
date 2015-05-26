React = require('react')
{DropDownMenu, TextField} = require 'material-ui'
userStore = require '../../stores/UserStore.coffee'

ContactVariableForm = React.createClass
  getInitialState: ->
    fieldTypes: [
      { payload: 'text', text: 'Text' }
      { payload: 'date', text: 'Date' }
      { payload: 'boolean', text: 'CheckBox' }
    ]

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

  getNewVariable:(e)->
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

    return newVariable

  render: ->
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

module.exports = ContactVariableForm