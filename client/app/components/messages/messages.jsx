import React from 'react';
import {TextField, FontIcon, RaisedButton} from 'material-ui';
import styles from './messages.styl'

class Messages extends React.Component {
    render() {
        return (

          <form className="message-form">
            <TextField
              hintText="Phone number"
              className="phoneInput"
              floatingLabelText="Enter phone number" />

            <TextField
              hintText="Message text"
              className="msgInput"
              multiLine={true} />


            <RaisedButton className="sendButton" linkButton={true} secondary={true} >
              <FontIcon className="button-icon icon-paperplane"/>
              <span className="mui-raised-button-label example-icon-button-label">Send</span>
            </RaisedButton>
          </form>
        );
    }
}

export default Messages
