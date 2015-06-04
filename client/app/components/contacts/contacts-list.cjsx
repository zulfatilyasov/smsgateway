React = require 'react'
ContactItem = require './contact-item.cjsx'
contactActions = require '../../actions/ContactActions.coffee'
userActions = require '../../actions/UserActions.coffee'
contactStore = require '../../stores/ContactStore.coffee'
userStore = require '../../stores/UserStore.coffee'
_ = require 'lodash'
ui = require '../../services/ui.coffee'
State = require('react-router').state
InfiniteScroll = require('react-infinite-scroll')(React)

_animationOff = false
animateItems = ->
    delay = if _animationOff  then 0 else 20
    $('.animated').each (i, el) ->
        unless $(@).is('.active')
            $(@)
                .css("-webkit-transition-delay", i*delay+'ms')
                .css("-o-transition-delay", i*delay+'ms')
                .css("transition-delay", i*delay+'ms')
                .addClass('active')

getState = ->
    contacts: contactStore.ContactList()
    loading: contactStore.InProgress()
    hasMore: true

ContactList = React.createClass

    mixins: [ State ]

    getInitialState: ->
        getState()

    checkLoadMore: ->
        if contactStore.hasMore() and not @appendingContacts and ui.bottomDistance() < 1600
            @loadMoreContacts()

    componentDidMount: ->
        $('.toobarWrap').scrollToFixed()
        window.onscroll = _.debounce @checkLoadMore, 250
        contactStore.addChangeListener(@onChange)
        userId = userStore.userId();
        groupId = @props.params.groupId;
        if userStore.isAuthenticated()
            contactActions.getUserContacts(userId, groupId)
            contactActions.getUserGroups(userId);
        else
            userActions.logout()
        animateItems()

    componentWillUnmount: ->
        contactStore.removeChangeListener(@onChange)
        contactActions.clean()

    hideLoadingMessage: ->
        setTimeout ->
            $('.loading').removeClass('open')
        , 750

    onChange: ->
        @hideLoadingMessage()
        @setState getState()

    loadMoreContacts: (pageId) ->
        _animationOff = true
        $('.loading').addClass('open')
        setTimeout =>
            @appendingContacts = true
            userId = userStore.userId();
            groupId = @props.params.groupId;
            pageId = contactStore.pageId()
            console.log pageId
            contactActions.getUserContacts(userId, groupId, pageId * 50)
        , 200

    componentDidUpdate: (prevProps, prevState) ->
        animateItems()
        @appendingContacts = false

    render: ->
        ContactList = <div>
                        {
                            for contact in @state.contacts
                                contact.key = contact.id
                                <ContactItem {...contact} />
                        }
                      </div>
        <div>
            {
                if @state.contacts.length
                    <div>
                        {ContactList}
                    </div>
                else
                    if @state.loading
                        <div className="no-messages">Loading...</div>
                    else 
                        <div className="no-messages">No contacts</div>
            }
            <div>
            {
                <div className="loading">Loading...</div>
            }
            </div>
        </div>

module.exports = ContactList