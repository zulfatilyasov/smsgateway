React = require('react')
classBuilder = require('classnames')
messageActions = require '../../actions/MessageActions.coffee'
$ = require '../../services/zepto.js'
{DropDownIcon, FontIcon} = require('material-ui')

getItemStatusText  = (item) ->
    if item.incoming
        return 'Received from:'
    if item.status is 'sent'
        return 'Sent to:'
    if item.status is 'failed'
        return 'Failed:'
    if item.status is 'sending'
        return 'Sending...'

MessageItem = React.createClass
  
  menuClicked: (e, key, data) ->
    @toggleZIndex()
    if data.payload is 'star'
      messageActions.updateUsersMessageStar(@props.userId, @props.id, !@props.starred)

    if data.payload is 'resend'
      messageActions.resend
        address:@props.address
        body:@props.body 

  getInitialState: ->
    {zindex: 'auto'}

  toggleZIndex:()->
    if @state.zindex > 10
      @setState({zindex:'auto'})
    else
      @setState({zindex:98})

  componentDidMount: ->
    if @props.new
      $(this.getDOMNode()).addClass('active')
      
    $(this.getDOMNode()).find('.mui-menu-control')[0].onclick = @toggleZIndex

  render: ->
    starText = if @props.starred then 'Unstar' else 'Star'
    iconMenuItems = [
      { payload: 'star', text: starText}
      { payload: 'resend', text: 'Resend'}
    ]

    iconClassName = classBuilder
        'icon-arrow-with-circle-left outcoming': @props.status is 'sent'
        'icon-paper-plane sending': @props.status is 'sending'
        'icon-arrow-with-circle-right incoming': @props.incoming
        'icon-sms-failed fail': @props.status is 'failed'

    statusClass = classBuilder
        success: @props.status is 'sent'
        fail: @props.status is 'failed'
        sending: @props.status is 'sending'
        received: @props.incoming is true

    statusText = getItemStatusText(@props)

    style = {zIndex:@state.zindex}

    <div style={style} className="message-item animated">
      <div className="message-icon">
        <FontIcon className={iconClassName} />
      </div>
      <div className="message-inner">
        <div className="address">
          <span className={statusClass}>{statusText}</span> {@props.address}
        </div>
        <div className="body">
          {@props.body}
        </div>
      </div>
      <div className="message-actions">
        {
          if @props.starred
            <div className="star">
              <FontIcon className="icon icon-star" />
            </div>
        }
        <DropDownIcon className="menu-icon" onChange={@menuClicked} onClick={@toggleZIndex} iconClassName="icon icon-dots-three-vertical" menuItems={iconMenuItems} />
      </div>
    </div>

module.exports = MessageItem