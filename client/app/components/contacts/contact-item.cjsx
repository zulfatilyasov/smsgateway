React = require('react')
classBuilder = require('classnames')
contactActions = require '../../actions/ContactActions.coffee'
{Checkbox, FontIcon} = require 'material-ui'
PureRenderMixin = require('react/addons').addons.PureRenderMixin


ContactItem = React.createClass
  mixins: [PureRenderMixin]
  
  handleSelected: (e)->
    contactActions.selectSingle(@props.id)

  componentDidUpdate: (prevProps, prevState) ->
    @refs.checkbox.setChecked(@props.checked)

  componentDidMount: ->
    if @props.new
      $(@getDOMNode()).addClass('active')

  handleClick:(e) ->
    contactActions.editContact(@props)

  render: ->
    <div className="list-item animated">
      <div onClick={@handleClick} className="list-item-icon">
        <FontIcon className="icon icon-person-outline" />
      </div>
      <div onClick={@handleClick} className="list-item-inner">
        <div className="address">
          <span className="contact-name">{@props.name}</span>
        </div>
        <div className="body">
          <div className="contacts">
            {@props.phone}
          </div>
          {
            if @props.groups?.length
              <div className="groups">
                  {
                    for group, i in @props.groups
                      <span key={group.id}>
                        <span>{group.name}</span>
                        {
                          if i < @props.groups.length - 1
                            <span>, </span>
                        }
                      </span>
                  }
              </div>
          }
        </div>
      </div>
      <div className="list-item-actions">
        <Checkbox ref="checkbox" className="contact-checkbox" defaultSwitched={false} onCheck={@handleSelected} value="false"/>
      </div>
    </div>

module.exports = ContactItem