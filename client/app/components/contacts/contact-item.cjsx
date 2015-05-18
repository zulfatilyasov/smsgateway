React = require('react')
classBuilder = require('classnames')
contactActions = require '../../actions/ContactActions.coffee'
$ = require '../../services/zepto.js'
{Checkbox, FontIcon} = require 'material-ui'

ContactItem = React.createClass
  handleSelected: ()->
    contactActions.selectSingle(@props.id)

  componentDidUpdate: (prevProps, prevState) ->
    @refs.checkbox.setChecked(@props.checked)

  componentDidMount: ->
    if @props.new
      $(@getDOMNode()).addClass('active')

  render: ->
    <div className="list-item animated">
      <div className="list-item-icon">
        <FontIcon className="icon icon-person-outline" />
      </div>
      <div className="list-item-inner">
        <div className="address">
          <span className="contact-name">{@props.name}</span>
        </div>
        <div className="body">
          <div className="contacts">
            {@props.phone}
          </div>
          {
            if @props.groups.length
              <div className="groups">
                  {
                    for group, i in @props.groups
                      <span>
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
        <Checkbox ref="checkbox" defaultSwitched={false} onCheck={@handleSelected} value="false"/>
      </div>
    </div>

module.exports = ContactItem