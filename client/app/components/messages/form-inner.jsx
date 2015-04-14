import React from 'react'
import {TextField,  FontIcon, RaisedButton} from 'material-ui';

class FormInner extends React.Component {
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
        return (
            <div className="pad">
                <TextField
                    hintText="Phone number"
                    className="phoneInput"
                    onChange={this._handlePhoneChange.bind(this)}
                    floatingLabelText="Enter phone number"/>

                <TextField
                    hintText="Message text"
                    floatingLabelText="Enter message text"
                    onChange={this._handleTextChange.bind(this)}
                    className="msgInput"
                    multiLine={true}/>

                <RaisedButton className="sendButton" onClick={this._handleSendMessage.bind(this)} linkButton={true} secondary={true}>
                    <FontIcon className="button-icon icon-paperplane"/>
                    <span className="mui-raised-button-label example-icon-button-label">Send</span>
                </RaisedButton>
            </div>
        );
    }
}

export default FormInner