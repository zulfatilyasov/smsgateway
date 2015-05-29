import React from 'react'
import messageActions from  '../../actions/MessageActions.coffee';
import messageStore from '../../stores/MessageStore.es6';
import contactStore from '../../stores/ContactStore.coffee';
import userStore from '../../stores/UserStore.coffee';
import uiEvents from '../../uiEvents.coffee';
import {TextField,DropDownMenu, FontIcon, FlatButton, RaisedButton} from 'material-ui';
import Select from 'react-select'
import _ from 'lodash'

class FormInner extends React.Component {
    constructor(props) {
        super(props);
        this.mounted = false;
        this.state = {
            sending: false,
            addressValue:'',
            addressKey:'address',
            bodyValue:'',
            bodyKey:'body',
            addressList:contactStore.addressList(),
            deviceModel: userStore.deviceModel()
        };
    }

    componentDidMount() {
        this.mounted = true;
        messageStore.addChangeListener(this._onChange.bind(this));
        contactStore.addChangeListener(this._onChange.bind(this));
        userStore.addChangeListener(this._onChange.bind(this));
    }

    componentWillUnmount() {
        this.mounted = false;
        messageStore.removeChangeListener(this._onChange.bind(this));
        contactStore.removeChangeListener(this._onChange.bind(this));
        userStore.removeChangeListener(this._onChange.bind(this));
    }

    getState(){
        var state = {
            sending: messageStore.IsSending,
            addressList:contactStore.addressList(),
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
        if(this.mounted){
            this.setState(this.getState());
        }
    }

    _addressChanged(val, values){
        this.selectedAddresses = values;
    }

    _handleTextChange(e) {
        this.body = e.target.value;
    }

    _getConfirmationActions(submitClickHandler){
        return {
            submit:function () {
                uiEvents.closeDialog();
                submitClickHandler(); 
            },
            cancel:function () {
                uiEvents.closeDialog();
            }
        };
    }

    _confirmContinueWithoutDevice(submitAction){
        var actions = this._getConfirmationActions(submitAction);
        uiEvents.showDialog({
            title:"No device found",
            text: "No device was connected to send message. Click Ok to continue.",
            submitHandler:actions.submit,
            cancelHandler:actions.cancel
        });
    }

    _confirmWrongPhone(submitAction){
        var actions = this._getConfirmationActions(submitAction);
        uiEvents.showDialog({
            title:"Phone validation warning.",
            text: "Not a valid phone number.\nContinue?",
            submitHandler:actions.submit,
            cancelHandler:actions.cancel
        });
    }

    _alertCantUseNexmo(){
        uiEvents.showDialog({
            title:"Nexmo not available yet",
            text: "Can\'t use nexmo api yet, please select another provider",
            submitHandler:function () {
                uiEvents.closeDialog();
            }
        });
    }

    _handleSendMessage(e) {
        e.preventDefault();
        var self = this;
        var userId = userStore.userId();
        var recipients = contactStore.stripContacts(this.selectedAddresses, userId);
        var message = {
            body: self.body,
            userId: userId,
            status: 'queued',
            outcoming: true,
            handler: self.provider,
            origin: 'web'
        };


        var sendToSingleAddress = function () {
            var messageAddress = recipients.contacts[0].phone;
            var address = messageAddress.replace(/[^0-9]/g, '');
            if(address.length < 8 || address.length > 12) { 
                self._confirmWrongPhone(function () {
                    messageActions.sendToMultipleContacts(message, recipients.contacts, recipients.groupIds);
                });
            }
            else {
                messageActions.sendToMultipleContacts(message, recipients.contacts, recipients.groupIds);
            }            
        };

        var send = function () {
            if (self.handler === 'api'){
                self._alertCantUseNexmo();
                return;
            }
            if(recipients.contacts.length === 1 && recipients.groupIds.length===0){
                sendToSingleAddress();
            } else {
                messageActions.sendToMultipleContacts(message, recipients.contacts, recipients.groupIds);
            }
        };

        if (!self.provider){
            self._confirmContinueWithoutDevice(send);
        } else {
            send();
        }
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
        } else{
            this.provider = null
        }

        var primaryButtonLabel = this.state.sending ? 'Sending..' : 'Send';

        return (
            <div className="message-form pad">
                <div className="formInner">
                    <Select
                        multi={true}
                        options={this.state.addressList}
                        allowCreate={true}
                        placeholder="Address"
                        className="input phoneInput"
                        onChange={this._addressChanged.bind(this)} />

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
                            <RaisedButton
                                className={sendButtonClass}
                                primary={true}
                                disabled={this.state.sending}
                                onClick={this._handleSendMessage.bind(this)}
                                linkButton={true}
                                label={primaryButtonLabel} >
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