React = require 'react'
{Paper} = require 'material-ui'
ReactCSSTransitionGroupAppear = require '../../react-helpers/ReactCSSTransitionAppear.jsx'

Dashboard = React.createClass
    render: ->
        <Paper zDepth={1}>
            <div className="section">
                <div className="section-header">
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown">
                        <h2>Dashboard</h2>
                    </ReactCSSTransitionGroupAppear>
                    <ReactCSSTransitionGroupAppear transitionName="fadeDown2">
                        <h4>not implented yet</h4>
                    </ReactCSSTransitionGroupAppear>
                </div>
                <div className="section-body">
                    <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
                    <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
                </div>
            </div>
        </Paper>
        
module.exports = Dashboard