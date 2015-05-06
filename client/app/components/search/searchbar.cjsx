React = require('react')
{TextField, RaisedButton} = require('material-ui')

SearchBar = React.createClass

  handleSearchChange:(e) ->
    console.log e.target.value

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