React = require 'react'
ContactItem = require './contact-item.cjsx'
contactActions = require '../../actions/ContactActions.coffee'
userActions = require '../../actions/UserActions.coffee'
contactStore = require '../../stores/ContactStore.coffee'
userStore = require '../../stores/UserStore.coffee'
$ = require '../../services/zepto.js'
State = require('react-router').state

animateItems = ->
    delay = 20
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

ContactList = React.createClass

    mixins: [ State ]

    getInitialState: ->
        getState()

    componentDidMount: ->
        contactStore.addChangeListener(@onChange)
        userId = userStore.userId();
        groupId = @props.params.groupId;
        if userStore.isAuthenticated()
            contactActions.getUserContacts(userId, groupId)
        else
            userActions.logout()
        animateItems()

    componentWillUnmount: ->
        contactStore.removeChangeListener(@onChange)
        contactActions.clean()

    onChange: ->
        @setState getState()

    componentDidUpdate: (prevProps, prevState) ->
        animateItems()

    render: ->
        ContactList = <div>
                        {
                            for contact in @state.contacts by -1
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
        </div>

module.exports = ContactList