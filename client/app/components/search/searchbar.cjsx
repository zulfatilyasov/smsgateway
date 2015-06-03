React = require('react')
messageActions = require '../../actions/MessageActions.coffee'
userStore = require '../../stores/UserStore.coffee'
{TextField, RaisedButton} = require('material-ui')
_ = require 'lodash'

SearchBar = React.createClass
  componentDidMount: ->
    @search = _.debounce @props.search, 300

  handleSearchChange:(e) ->
    @search(e.target.value)

  render: ->
    <div className="search">
      <div className="pad">
        <TextField
            hintText="Search"
            className="input searchInput"
            onChange={@handleSearchChange} />

        <RaisedButton className="close" primary={true} label="Close" onClick={@props.closeClickHandler}>
        </RaisedButton>
      </div>
    </div>

module.exports = SearchBar