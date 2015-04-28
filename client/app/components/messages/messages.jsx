import React from 'react';
import {TextField,Tabs, Tab, Paper, FontIcon, RaisedButton} from 'material-ui';
import Table from '../table/table.jsx';
import styles from './messages.styl';
import FormElements from './form-inner.jsx';
import messageStore from '../../stores/MessageStore.es6';
import userStore from '../../stores/UserStore.coffee';
import messageActions from '../../actions/MessageActions.coffee';
import userActions from '../../actions/UserActions.coffee';
var ReactCSSTransitionGroup = React.addons.CSSTransitionGroup;

function getState() {
    return {
        messages: messageStore.MessageList
    }
}

class Messages extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            mounted:false,
            messages:messageStore.MessageList
        };
    }

    componentDidMount() {
        this.setState({ mounted: true });
        var userId = userStore.userId();
        if(!userId){
            userActions.logout();
            return
        }
        debugger;
        messageActions.getUserMessages(userId);
        messageStore.addChangeListener(this._onChange.bind(this));
    }

    componentWillUnmount() {
        messageStore.removeChangeListener(this._onChange.bind(this));
    }

    _onChange() {
        console.log('called on changed messages.jsx')
        if(this.state.mounted){
            this.setState(getState());
        }
    }

    _onActive() {
        this.context.router.transitionTo(tab.props.route);
    }

    render() {
        var content = this.state.messages.length ? <Table rowItems={this.state.messages}/> : <div className="no-messages">No messages</div>;
        return (
            <div className="message-form-wrap">
                <Paper zDepth={1}>
                    <form className="message-form">
                        <ReactCSSTransitionGroup transitionName="fadeDown">
                            <h2>Outcoming Messages</h2>
                        </ReactCSSTransitionGroup>
                        <h4>Compose new message</h4>
                    </form>
                    <div className="section-body">
                        <div>
                            <FormElements/>
                        </div>
                        <div className="messages-list">
                            {content}
                        </div>
                    </div>
                </Paper>
            </div>
        );
    }
}

export default Messages
