import React from 'react'
import mui, {Paper} from 'material-ui'

class Settings extends React.Component {
    render() {
        return (
            <Paper zDepth={1}>
                <form className="message-form">
                    <h2>Settings</h2>
                    <h4>Subscription and others</h4>
                </form>
                <div className="messages-list">
                    <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
                    <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
                </div>
            </Paper>
        );
    }
}
export default Settings