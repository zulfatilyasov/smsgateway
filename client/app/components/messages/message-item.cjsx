React = require('react')
classBuilder = require('classnames')
messageActions = require '../../actions/MessageActions.coffee'
$ = require '../../services/zepto.js'
{Checkbox, DropDownIcon, FontIcon} = require('material-ui')

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

    if data.payload is 'delete'
      if confirm "Delete this message permanently?"
        messageActions.deleteMessage(@props.userId, @props.id)

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

  handleSelected: ()->
    messageActions.selectSingle(@props.id)

  componentDidUpdate: (prevProps, prevState) ->
    @refs.checkbox.setChecked(@props.checked)

  componentDidMount: ->
    if @props.new
      $(this.getDOMNode()).addClass('active')

  render: ->
    starText = if @props.starred then 'Unstar' else 'Star'
    iconMenuItems = [
      { payload: 'star', className:'menu-star', text: starText}
      { payload: 'resend',className:'menu-resend', text: 'Resend'}
      { payload: 'delete', className:'menu-delete', text: 'Delete'}
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
          <span className={statusClass}>{statusText}</span>
          <span className="message-address">
           {@props.address}
          </span>
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
        <Checkbox ref="checkbox" defaultSwitched={false} onCheck={@handleSelected} value={false}/>
      </div>
    </div>

module.exports = MessageItem