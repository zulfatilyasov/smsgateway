React = require 'react'
MessageItem = require './message-item.cjsx'
messageStore = require '../../stores/MessageStore.es6'
userStore = require '../../stores/UserStore.coffee'
messageActions = require '../../actions/MessageActions.coffee'
ui = require '../../services/ui.coffee'

_animationOff = false
animateItems = ->
    delay = if _animationOff then 0 else 20
    $('.animated').each (i, el) ->
        unless $(@).is('.active')
            $(@)
                .css("-webkit-transition-delay", i*delay+'ms')
                .css("-o-transition-delay", i*delay+'ms')
                .css("transition-delay", i*delay+'ms')
                .addClass('active')

MessageList = React.createClass
    hideLoadingMessage: ->
        setTimeout ->
            $('.loading').removeClass('open')
        , 1500

    checkLoadMore: ->
        if not @appendingContacts and messageStore.HasMore and ui.bottomDistance() < 1300
            @loadMoreMessages()

    getInitialState: ->
        {loadingContacts:false }

    loadMoreMessages: (pageId) ->
        _animationOff = true
        $('.loading').addClass('open')
        setTimeout =>
            @appendingContacts = true
            pageId = messageStore.PageId
            console.log pageId
            userId = userStore.userId();
            messageActions.getUserMessages(userId, 'all', pageId * 50)
        , 200

    componentDidMount: ->
        $('.toobarWrap').scrollToFixed()
        window.onscroll = _.debounce @checkLoadMore, 250
        messageStore.addChangeListener @onChange
        animateItems()

    componentWillUnmount: ->
        messageStore.removeChangeListener @onChange

    onChange:->
        @hideLoadingMessage()

    componentDidUpdate: (prevProps, prevState) ->
        animateItems()
        @appendingContacts = false

    render: ->
        <div>
            {
                for msg in @props.messages
                    msg.key = msg.id
                    <MessageItem {...msg} />
            }
            <div>
                {
                    <div className="loading">Loading...</div>
                }
            </div>
        </div>

    

module.exports = MessageList