React = require('react')
{TextField} = require 'material-ui'

GroupForm = React.createClass

  getInitialState: ->
    {showInput: false}

  handleSubmit: (e) ->
    e.preventDefault()
    console.log @groupName
    @setState
      showInput: false

  handleNameChange:(e) ->
    @groupName = e.target.value
  
  toggleInput:(e)->
    @setState
      showInput: !@state.showInput

  render: ->
    <div className="mui-menu-item menuForm">
      {
        if @state.showInput
          <form onSubmit={@handleSubmit}>
            <TextField
              hintText="Group name"
              onChange={@handleNameChange}
              className="group-name-input"/>
          </form>
        else
          <div onClick={@toggleInput} className="add-group-label"> 
            Add Group
          </div>
      }
    </div>

module.exports = GroupForm