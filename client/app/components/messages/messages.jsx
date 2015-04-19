import React from 'react';
import {TextField,Tabs, Tab, Paper, FontIcon, RaisedButton} from 'material-ui';
import Table from '../table/table.jsx';
import styles from './messages.styl';
import FormElements from './form-inner.jsx';
import messageActions from '../../actions/MessageActions.es6';
import messageStore from '../../stores/MessageStore.es6';

function getState() {
    return {
        messages: messageStore.MessageList
    }
}

class Messages extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            messages:messageStore.MessageList
        };
    }

    componentDidMount() {
        messageStore.addChangeListener(this._onChange.bind(this));
    }

    componentWillUnmount() {
        messageStore.removeChangeListener(this._onChange.bind(this));
    }

    _onChange() {
        this.setState(getState());
    }

    _onActive() {
        this.context.router.transitionTo(tab.props.route);
    }

    render() {
        return (
            <div>
                <Paper zDepth={1}>
                    <form className="message-form">
                        <h2>Outcoming Messages</h2>
                        <h4>Compose new message</h4>
                    </form>
                    <div className="section-body">
                        <div>
                            <FormElements/>
                        </div>
                        <div className="messages-list">
                            <Table rowItems={this.state.messages}/>
                        </div>
                    </div>
                </Paper>
            </div>
        );
    }
}

export default Messages
