React = require('react')
contactStore = require '../../stores/ContactStore.coffee'
contactActions = require '../../actions/ContactActions.coffee'
{Checkbox, DropDownMenu, DatePicker, RaisedButton, TextField} = require 'material-ui'

defaultVariabels = [{
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
    ]
Filter = React.createClass

  getInitialState: ->
    @filters = {}
    @operators = {}
    {variables: @getVariables()}

  getVariables: ->
    vars = contactStore.origVariables()
    for vr in vars
      vr.isVariable = true

    vars = defaultVariabels.concat(vars)
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

    propertyFilter =
      isVariable: isVariable
      value: value
      operator: @operators[propName]

    @filters[propName] = propertyFilter

  handleFilterClick:(e)->
    contactActions.filter @filters

  datePropChanged:(isVariable, dateInputType, propName, e, value)->
    filter =
      isVariable: isVariable
      value: value

    if not @filters[propName]
      @filters[propName] = {}

    if dateInputType is 'from'
      filter.operator = 'gt'
    else
      filter.operator = 'lt'

    @filters[propName] = filter

  render: ->
    menuItems =[
      { payload: 'contains', text: 'Contains' }
      { payload: 'startsWith', text: 'Starts with' }
      { payload: 'endsWith', text: 'Ends with' }
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

      <div className="actions">
        <RaisedButton  className="close" primary={false} label="Close" onClick={@props.closeClickHandler}>
        </RaisedButton>
        <RaisedButton onClick={@handleFilterClick} className="filter" primary={true} label="Filter">
        </RaisedButton>
      </div>
    </div>

module.exports = Filter