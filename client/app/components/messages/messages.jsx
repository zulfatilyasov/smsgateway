import React from 'react';
import {TextField,Tabs, Tab, Paper, FontIcon, RaisedButton} from 'material-ui';
import Table from '../table/table.jsx';
import styles from './messages.styl';
import FormElements from './form-inner.jsx';
import messageActions from '../../actions/MessageActions.es6';

class Messages extends React.Component {
    _onActive(){
        this.context.router.transitionTo(tab.props.route);
    }
    render() {
        return (
            <div>
                <Paper zDepth={1}>
                    <form className="message-form">
                        <h2>Outcoming messages</h2>
                        <h4>All messages list</h4>
                    </form>
                    <div className="messages-list">
                        <Table />
                    </div>
                </Paper>
            </div>
        );
    }
}

export default Messages
