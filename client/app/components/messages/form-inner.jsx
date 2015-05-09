import React from 'react'
import messageActions from  '../../actions/MessageActions.coffee';
import messageStore from '../../stores/MessageStore.es6';
import userStore from '../../stores/UserStore.coffee';
import {TextField,DropDownMenu, FontIcon, FlatButton, RaisedButton} from 'material-ui';

class FormInner extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            sending: false,
            mounted:false,
            addressValue:'',
            addressKey:'address',
            bodyValue:'',
            bodyKey:'body',
            deviceModel: userStore.deviceModel()
        }
    }

    componentDidMount() {
        this.setState({mounted:true});
        messageStore.addChangeListener(this._onChange.bind(this));
        userStore.addChangeListener(this._onChange.bind(this));
    }

    componentWillUnmount() {
        messageStore.removeChangeListener(this._onChange.bind(this));
        userStore.removeChangeListener(this._onChange.bind(this));
    }

    getState(){
        var state = {
            sending: messageStore.IsSending,
            deviceModel: userStore.deviceModel()
        };

        if (messageStore.MessageToResend){
            state.addressKey = messageStore.MessageToResend.address;
            state.addressValue = messageStore.MessageToResend.address;
            this.address = messageStore.MessageToResend.address;
            state.bodyValue = messageStore.MessageToResend.body;
            state.bodyKey = messageStore.MessageToResend.body;
            this.body = messageStore.MessageToResend.body;
        }

        return state;
    }

    _onChange() {
        if(this.state.mounted){
            this.setState(this.getState());
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
        if (!this.provider){
            alert('Need a message provider to send sms.');
            return;
        }
        if (this.provider === 'api'){
            alert('Can\'t use nexmo api yet, please select another provider');
            return;
        }

        var message = {
            body: this.body,
            status: 'sending',
            address: this.address,
            outcoming: true,
            origin: 'web'
        };
       
        messageActions.send(message);
    }

    _providerChanged(e, selectedIndex, menuItem){
        this.provider = menuItem.payload;
    }

    render() {

        var className = this.state.sending ? 'sending' : '';
        var sendButtonClass = 'sendButton ' + className;

        var menuItems = [
           { payload: 'phone', text: 'Phone - ' + this.state.deviceModel },
           { payload: 'api', text: 'Nexmo api' }
        ];

        var devices = <div className="no-device">No device connected</div>;
        if (this.state.deviceModel){
            this.provider = menuItems[0].payload;
            devices = <DropDownMenu className="handlers" onChange={this._providerChanged.bind(this)} menuItems={menuItems} />;
        }

        var primaryButtonLabel = this.state.sending ? 'Sending..' : 'Send';

        return (
            <div className="pad">
                <div className="formInner">
                    <TextField
                        key={this.state.addressKey}
                        hintText="Enter message address"
                        defaultValue={this.state.addressValue}
                        className="input phoneInput"
                        onChange={this._handlePhoneChange.bind(this)}
                        floatingLabelText="Address"/>

                    <TextField
                        hintText="Enter message body"
                        floatingLabelText="Body"
                        key={this.state.bodyKey}
                        defaultValue={this.state.bodyValue}
                        onChange={this._handleTextChange.bind(this)}
                        className="input msgInput"
                        multiLine={true}/>


                    <div className="selectMessageHandler">
                        <div className="handlersLabel">Send message with:</div>
                        {devices}
                    </div>

                    <div className="button-wrap">
                        <div className="buttons">
                            <RaisedButton className={sendButtonClass}
                                          primary={true}
                                          disabled={this.state.sending}
                                          onClick={this._handleSendMessage.bind(this)}
                                          linkButton={true}>
                                <FontIcon className="button-icon icon-paperplane"/>
                                <span className="mui-raised-button-label icon-button-label">{primaryButtonLabel}</span>
                            </RaisedButton>

                            <RaisedButton className="cancel-button" onClick={this.props.cancelClickHandler} linkButton={true}>
                                <span className="mui-raised-button-label">Cancel</span>
                            </RaisedButton>
                        </div>
                    </div>
                </div>
            </div>
        );
    }
}

export default FormInner