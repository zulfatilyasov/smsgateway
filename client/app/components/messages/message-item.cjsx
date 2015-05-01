React = require('react')
classBuilder = require('classnames')
{FontIcon} = require('material-ui')

MessageItem = React.createClass

  render: ->
    iconClassName = classBuilder
        'icon-arrow-with-circle-left outcoming': @props.outcoming
        'icon-arrow-with-circle-right incoming': @props.incoming

    <div className="message-item">
      <div className="message-icon">
        <FontIcon className={iconClassName} />
      </div>
      <div className="message-inner">
        <div className="address">
          Sent to: {@props.address}
        </div>
        <div className="body">
          <i>{@props.body}</i>
        </div>
      </div>
    </div>

module.exports = MessageItem