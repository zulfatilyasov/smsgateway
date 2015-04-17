import React from 'react'
import messageActions from  '../../actions/MessageActions.es6';
import messageStore from '../../stores/MessageStore.es6';
import Spinner from '../spinner/spinner.jsx';
import {TextField,  FontIcon,FlatButton, RaisedButton} from 'material-ui';

function getState() {
    return {
        sending: messageStore.IsSending
    };
}

class FormInner extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            sending: false
        }
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

    _handlePhoneChange(e) {
        this.recipientPhone = e.target.value;
    }

    _handleTextChange(e) {
        this.text = e.target.value;
    }

    _handleSendMessage() {
        var message = {
            text: this.text,
            recipient: this.recipientPhone
        };

        messageActions.send(message);
    }

    render() {

        var className = this.state.sending ? 'hide' : '';
        var sendButtonClass = 'sendButton ' + className;

        return (
            <div className="pad">
                <div className="formInner">
                    <TextField
                        hintText="Phone number"
                        className="input phoneInput"
                        onChange={this._handlePhoneChange.bind(this)}
                        floatingLabelText="Enter phone number"/>

                    <TextField
                        hintText="Message text"
                        floatingLabelText="Enter message text"
                        onChange={this._handleTextChange.bind(this)}
                        className="input msgInput"
                        multiLine={true}/>

                    <div className="button-wrap">
                        <Spinner width="40px" height="40px" show={this.state.sending}/>

                        <RaisedButton className={sendButtonClass} onClick={this._handleSendMessage.bind(this)} linkButton={true}>
                            <FontIcon className="button-icon icon-paperplane"/>
                            <span className="mui-raised-button-label icon-button-label">Send</span>
                        </RaisedButton>
                    </div>
                </div>
            </div>
        );
    }
}

export default FormInner