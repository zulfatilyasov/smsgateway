React = require('react')
classBuilder = require('classnames')
{FontIcon} = require('material-ui')

getItemStatusText  = (item) ->
    if item.incoming
        return 'Received from:'
    if item.status is 'sent'
        return 'Sent to:'
    if item.status is 'failed'
        return 'Failed'
    if item.status is 'sending'
        return 'Sending'

MessageItem = React.createClass

  render: ->
    iconClassName = classBuilder
        'icon-arrow-with-circle-left outcoming': @props.outcoming
        'icon-arrow-with-circle-right incoming': @props.incoming

    statusClass = classBuilder
        success: @props.status is 'sent'
        fail: @props.status is 'failed'
        sending: @props.status is 'sending'
        received: @props.incoming is true

    statuText = getItemStatusText(@props)

    <div className="message-item animated">
      <div className="message-icon">
        <FontIcon className={iconClassName} />
      </div>
      <div className="message-inner">
        <div className="address">
          <span className={statusClass}>{statuText}</span> {@props.address}
        </div>
        <div className="body">
          {@props.body}
        </div>
      </div>
    </div>

module.exports = MessageItem