var React = require('react');
var mui = require('material-ui');
var TextField = mui.TextField;
var SubComponent = React.createClass({
    render () {
        return (
            <div>
                <h1>SUB COMPONENT!</h1>

                <h2>Message : {this.props.message}</h2>
                <TextField
                    hintText="Email"
                    floatingLabelText="Your email please"/>
            </div>
        );
    }
});

module.exports = SubComponent;
