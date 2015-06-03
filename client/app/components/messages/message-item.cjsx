React = require('react')
classBuilder = require('classnames')
messageActions = require '../../actions/MessageActions.coffee'
{Checkbox, DropDownIcon, FontIcon} = require('material-ui')
fecha = require 'fecha'
PureRenderMixin = require('react/addons').addons.PureRenderMixin

getItemStatusText  = (item) ->
    if item.incoming
        return 'Received from: '
    if item.status is 'sent'
        return 'Sent: '
    if item.status is 'failed'
        return 'Failed: '
    if item.status is 'queued' or item.status is 'sending'
        return 'Queued: '
    if item.status is 'cancelled'
        return 'Cancelled: '

MessageItem = React.createClass
  mixins: [PureRenderMixin]

  handleSelected: ()->
    messageActions.selectSingle(@props.id)

  componentDidUpdate: (prevProps, prevState) ->
    @refs.checkbox.setChecked(@props.checked)

  componentDidMount: ->
    if @props.new
      $(@getDOMNode()).addClass('active')

  render: ->
    starText = if @props.starred then 'Unstar' else 'Star'
    iconClassName = classBuilder
        'icon-arrow-up-left2 outcoming': @props.status is 'sent'
        'icon-paper-plane sending queued': @props.status is 'sending' or @props.status is 'queued'
        'icon-arrow-down-right2 incoming': @props.incoming
        'icon-sms-failed fail': @props.status is 'failed'
        'icon-close cancelled': @props.status is 'cancelled'

    lastAction = 'Sent'
    if @props.status is 'failed'
      lastAction = 'Failed'

    if @props.status is 'received'
      lastAction = 'Received'

    if @props.status is 'received'
      lastAction = 'Received'

    statusClass = classBuilder
        success: @props.status is 'sent'
        fail: @props.status is 'failed'
        sending: @props.status is 'sending' or @props.status is 'queued'
        received: @props.incoming is true

    statusText = getItemStatusText(@props)

    address = @props.address
    createDate = fecha.format(new Date(@props.addedOn), 'MM/DD/YY HH:mm')
    updateDate = fecha.format(new Date(@props.updatedOn), 'MM/DD/YY HH:mm')
    if @props.status is 'scheduled'
      names = _.map @props.address, (a) -> a.name 


    <div className="list-item animated">
      <div className="list-item-icon">
        <FontIcon className={iconClassName} />
      </div>
      <div className="list-item-inner">
        <div className="top-line">
          <div className="address">
            <span className={statusClass}>
             {statusText}
            </span>
            <span className="message-address">
              {@props.address}
            </span>
          </div>
          <div className="dates">
            <span>
              Created: {createDate}
            </span>
          </div>
        </div>
        <div className="bottom-line">
          <div className="body">
            {@props.body}
          </div>
          <div className="dates">
            {
              if updateDate and @props.addedOn isnt @props.updatedOn
                <span>
                   {lastAction}: {updateDate}
                </span>
            }
          </div>
        </div>
      </div>
      <div className="list-item-actions">
        {
          if @props.starred
            <div className="star">
              <FontIcon className="icon icon-star" />
            </div>
        }
        <Checkbox ref="checkbox" defaultSwitched={false} onCheck={@handleSelected} value="false"/>
      </div>
    </div>

module.exports = MessageItem