var React = require('react');
var ExampleStore = require('../stores/ExampleStore');
var ExampleActions = require('../actions/ExampleActions');
var mui = require('material-ui');
var RaisedButton = mui.RaisedButton;
var SubComponent = require('./subComponent.jsx');
var LoginForm = require('./login.jsx');

var getState = function () {
    return {
        message: ExampleStore.message
    };
};

var counter = 0;

var Application = React.createClass({

    getInitialState() {
        return getState();
    },

    componentDidMount() {
        ExampleStore.addChangeListener(this._onChange);
    },

    componentWillUnmount() {
        ExampleStore.removeChangeListener(this._onChange);
    },

    _onChange() {
        this.setState(getState());
    },

    _sendMessage() {
        counter += 5;
        ExampleActions.sendMessage('hello world! ' + counter);
    },

    render() {
        return (
            <div>
                <h1>Hello World!</h1>

                <h2>You can edit stuff in here and it will hot update</h2>
                <RaisedButton primary={true} label="Increment" onClick={this._sendMessage}/>
                <br/>
                <br/>
                <SubComponent message={this.state.message}/>
            </div>
        );
    }

});

module.exports = Application