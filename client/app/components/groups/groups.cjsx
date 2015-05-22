React = require('react')
contactActions = require '../../actions/ContactActions.coffee'
userStore = require '../../stores/UserStore.coffee'
contactStore = require '../../stores/ContactStore.coffee'
{TextField, RaisedButton} = require('material-ui')
Select = require('react-select')
_ = require 'lodash'

getNewGroups = (groups) ->
  newOnes = _.filter groups, (g) -> g.value is g.label
  _.map newOnes, (g) ->
      name: g.label
      id: null

Groups = React.createClass

  groupChanged:(a, values) ->
    @selectedGroups = values

  getInitialState: ->
    groups: contactStore.groupOptions()
    values: contactStore.selectedContactGroups()

  componentDidMount: ->
    contactStore.addChangeListener @onChange

  componentWillUnmount: ->
    contactStore.removeChangeListener @onChange

  saveClickHandler: ->
    userId = userStore.userId()
    newGroups = getNewGroups @selectedGroups
    groups = contactStore.getOriginalGroups @selectedGroups
    selectedContacts = contactStore.selectedContacts()
    aggregatedGroups = contactStore.getOriginalGroups contactStore.selectedContactGroups()
    console.log aggregatedGroups
    contactActions.checkNewGroupsAndUpdateContacts(userId, selectedContacts, groups, newGroups, aggregatedGroups)
    @props.closeClickHandler()

  onChange: ->
    @setState
      groups: contactStore.groupOptions()
      values: contactStore.selectedContactGroups()

  render: ->
    <div className="groups">
      <div className="pad">
        <Select
            multi={true}
            options={@state.groups}
            value={@state.values}
            allowCreate={true}
            placeholder="Groups"
            className="groups-select"
            onChange={@groupChanged} />
        <RaisedButton className="close" primary={true} label="Save" onClick={@saveClickHandler}>
        </RaisedButton>
        <RaisedButton className="close" primary={true} label="Close" onClick={@props.closeClickHandler}>
        </RaisedButton>
      </div>
    </div>

module.exports = Groups