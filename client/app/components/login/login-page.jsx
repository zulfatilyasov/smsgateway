import React from 'react';
import LoginForm  from './login.jsx';
import Overlay from '../overlay/overlay.jsx';
import Table from '../table/table.jsx';

class LoginPage extends React.Component {
    render() {
        return (
            <Overlay>
                <LoginForm>
                </LoginForm>
            </Overlay>
        );
    }
}

export default LoginPage;
