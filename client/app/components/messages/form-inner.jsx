import React from 'react'
import messageActions from  '../../actions/MessageActions.coffee';
import messageStore from '../../stores/MessageStore.es6';
import Spinner from '../spinner/spinner.cjsx';
import {TextField,  FontIcon, FlatButton, RaisedButton} from 'material-ui';

function getState() {
    return {
        sending: messageStore.IsSending
    };
}

class FormInner extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            sending: false,
            mounted:false
        }
    }

    componentDidMount() {
        this.setState({mounted:true});
        messageStore.addChangeListener(this._onChange.bind(this));
    }

    componentWillUnmount() {
        messageStore.removeChangeListener(this._onChange.bind(this));
    }

    _onChange() {
        if(this.state.mounted){
            this.setState(getState());
        }
    }

    _handlePhoneChange(e) {
        this.address = e.target.value;
    }

    _handleTextChange(e) {
        this.body = e.target.value;
    }

    _handleSendMessage(e) {
        e.preventDefault();

        var message = {
            body: this.body,
            status: 'sent',
            address: this.address,
            outcoming: true,
            origin: 'web'
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
                        hintText="Enter message address"
                        className="input phoneInput"
                        onChange={this._handlePhoneChange.bind(this)}
                        floatingLabelText="Address"/>

                    <TextField
                        hintText="Enter message body"
                        floatingLabelText="Body"
                        onChange={this._handleTextChange.bind(this)}
                        className="input msgInput"
                        multiLine={true}/>

                    <div className="button-wrap">
                        <Spinner width="40px" height="40px" show={this.state.sending}/>

                        <RaisedButton className={sendButtonClass} primary={true} onClick={this._handleSendMessage.bind(this)} linkButton={true}>
                            <FontIcon className="button-icon icon-paperplane"/>
                            <span className="mui-raised-button-label icon-button-label">Send</span>
                        </RaisedButton>

                        <RaisedButton className="cancel-button" onClick={this.props.cancelClickHandler} linkButton={true}>
                            <span className="mui-raised-button-label">Cancel</span>
                        </RaisedButton>
                    </div>
                </div>
            </div>
        );
    }
}

export default FormInner