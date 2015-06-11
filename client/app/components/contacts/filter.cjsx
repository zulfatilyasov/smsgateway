React = require('react')
contactStore = require '../../stores/ContactStore.coffee'
contactActions = require '../../actions/ContactActions.coffee'
{Dialog, Checkbox, DropDownMenu, DatePicker, FlatButton, RaisedButton, TextField} = require 'material-ui'
_ = require 'lodash'

defaultVariables = [{
        name:'Name'
        type:'text'
        code:'name'
        isVariable:false
      }
      {
        name:'Phone'
        type:'text'
        code:'phone'
        isVariable:false
      }
      {
        name:'Email'
        type:'text'
        code:'email'
        isVariable:false
      }
      {
        name:'Last Contacted'
        type:'date'
        code:'lastContacted'
        isVariable:false
      }

    ]
Filter = React.createClass

  getInitialState: ->
    @filters = {}
    @operators = {}

    selectableVariables : contactStore.variables()
    variables: @getVariables()

  getVariables: ->
    # vars = contactStore.origVariables()
    # for vr in vars
    #   vr.isVariable = true

    # vars = defaultVariables.concat(vars)
    vars = defaultVariables
    for v in vars
      if v.type is 'text'
        @operators[v.code] = 'contains'
      if v.type is 'boolean'
        @operators[v.code] = 'equals'
    return vars

  componentDidMount: ->
    contactStore.addChangeListener @onChange

  componentWillUnmount: ->
    contactStore.removeChangeListener @onChange
  
  onChange:->
    @setState
      selectableVariables : contactStore.variables()
      variables: @getVariables()

  handleOperationChange:(propName, e, index, item)->
    @operators[propName] = item.payload
    if @filters[propName]
      @filters[propName].operator = item.payload

  handlePropValueChange:(isVariable, e) ->
    value = null
    if e.target.type is 'text'
      value = e.target.value
    if e.target.type is 'checkbox'
      value = e.target.checked

    propName = e.target.name
    if not value and e.target.type is 'text'
      delete @filters[propName]
      return

    propertyFilter =
      isVariable: isVariable
      value: value
      operator: @operators[propName]

    @filters[propName] = propertyFilter
    console.log @filters

  handleFilterClick:(e)->
    contactActions.filter @filters

  handleAddCustomField:()->
    @refs.dialog.show()

  dialogCancelHandler:()->
    @refs.dialog.dismiss()

  dialogSubmitHandler:()->
    vars = @state.variables

    if not @selectedVar and @state.selectableVariables.length
      @selectedVar = @state.selectableVariables[0].payload

    if _.some @state.variables, {code:@selectedVar.code}
      @refs.dialog.dismiss()
      return

    @selectedVar.isVariable = true

    if @selectedVar.type is 'text'
      @operators[@selectedVar.code] = 'contains'
    if @selectedVar.type is 'boolean'
      @operators[@selectedVar.code] = 'equals'

    vars.push @selectedVar
    @setState
      variables: vars

    @refs.dialog.dismiss()

  handleVarSelected:(e, index, item)->
    @selectedVar = item.payload

  datePropChanged:(isVariable, dateInputType, name, e, value)->
    filter =
      isVariable: isVariable
      value: value
      code: name

    if dateInputType is 'from'
      filter.operator = 'gt'
    else
      filter.operator = 'lt'

    propName = name + filter.operator
    if not @filters[propName]
      @filters[propName] = {}

    @filters[propName] = filter
    console.log @filters

  render: ->
    menuItems =[
      { payload: 'contains', text: 'Contains' }
      { payload: 'startsWith', text: 'Starts with' }
      { payload: 'endsWith', text: 'Ends with' }
    ]
    filterButtonLabel = if @props.isFiltering then 'Filtering..' else 'Filter'
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

    getPropInputs = (prop) =>
      if prop.type is 'text'
        return <div>
                <DropDownMenu className="prop-value-input" onChange={@handleOperationChange.bind(@, prop.code)} menuItems={menuItems} />
                <TextField
                  floatingLabelText="Value"
                  type="text"
                  name={prop.code}
                  onChange={@handlePropValueChange.bind(@, prop.isVariable)}
                  className="prop-value-input"/>
              </div>
      if prop.type is 'date'
        return <div className="prop-dates">
                <div className="prop-value-input">
                  <DatePicker
                    name={prop.code}
                    type="from"
                    onChange={@datePropChanged.bind(@, prop.isVariable, 'from', prop.code)}
                    floatingLabelText="from Date"/>
                </div>
                <div className="prop-value-input">
                  <DatePicker
                    type="to"
                    name={prop.code}
                    onChange={@datePropChanged.bind(@, prop.isVariable, 'to', prop.code)}
                    floatingLabelText="to Date"/>
                </div>
              </div>

      if prop.type is 'boolean'
        return <div>
                <div className="prop-value-input">
                  <Checkbox
                    className="checkBox"
                    type='checkbox'
                    name={prop.code}
                    onCheck={@handlePropValueChange.bind(@, prop.isVariable)} />
                </div>
              </div>

    <div className="pad filter">
      {
        for prop,i in @state.variables
          <div key={prop.code + i} className="prop">
            <div className="prop-label">
              {prop.name}
            </div>
            <div className="prop-value">
              {
                getPropInputs(prop)
              }
            </div>
          </div>
      }

      <Dialog
        title="Add Custom Field"
        className="custom-field-dialog"
        ref="dialog"
        actions={dialogActions}>
        <div>
          <div>
            Please select custom field
          </div>
          <DropDownMenu key={@state.selectableVariables.length + 'variables'} onChange={@handleVarSelected} menuItems={@state.selectableVariables} />
        </div>
      </Dialog>


      <div className="actions">
        <RaisedButton  className="close" primary={false} label="Close" onClick={@props.closeClickHandler}>
        </RaisedButton>
        <RaisedButton onClick={@handleFilterClick} className="filter" primary={true} disabled={@props.isFiltering} label={filterButtonLabel}>
        </RaisedButton>
        <FlatButton className="add-field" secondary={true} label="Add Custom Field" onClick={@handleAddCustomField} />
      </div>
    </div>

module.exports = Filter