var React = require('react');

var Overlay = React.createClass({
    render() {
        return (
            <div className="overlay">
                {this.props.children}
            </div>
        )
    }
});

module.exports = Overlay;