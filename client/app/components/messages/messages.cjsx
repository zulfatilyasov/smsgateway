React = require 'react'
{Paper} = require 'material-ui'
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'
PageWithNav = require '../page-with-nav/page-with-nav.jsx'

Messages = React.createClass
    render: ->
        menuItems = [
            {route: 'allmessages', text: 'All messages',iconClassName:'icon icon-chat'}
            {route: 'outcoming', text: 'Outcoming', iconClassName:'icon icon-arrow-with-circle-left'}
            {route: 'incoming', text: 'Incoming',iconClassName:'icon icon-arrow-with-circle-right'}
            {route: 'starred', text: 'Starred',iconClassName:'icon icon-settings'}
        ]
        <Paper zDepth={1}>
            <div className="section">
                <div className="section-header">
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown">
                       <h2>Messages</h2>  
                    </ReactCSSTransitionGroupAppear>
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown2">
                       <h4>Search history or compose new message</h4>  
                    </ReactCSSTransitionGroupAppear>
                </div>

                <div className="section-body">
                    <PageWithNav menuItems={menuItems}/>
                </div>
            </div>
        </Paper>

module.exports = Messages