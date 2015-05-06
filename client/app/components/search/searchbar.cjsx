React = require('react')
messageActions = require '../../actions/MessageActions.coffee'
userStore = require '../../stores/UserStore.coffee'
{TextField, RaisedButton} = require('material-ui')
_ = require 'lodash'

search = (query) ->
  messageActions.searchUserMessages(userStore.userId(), query)

debouncedSearch = _.debounce search, 500

SearchBar = React.createClass

  handleSearchChange:(e) ->
    debouncedSearch(e.target.value)

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