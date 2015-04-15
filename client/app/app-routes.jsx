import React  from 'react';
import Router, {Route, Redirect, DefaultRoute}  from 'react-router';
import Master  from './master.jsx';
import Messages from './components/messages/messages.jsx';
import Settings  from './components/settings/settings.jsx';
import Contacts  from './components/contacts/contacts.jsx';
import Dashboard  from './components/dashboard/dashboard.jsx';

var AppRoutes = (
    <Route name="root" path="/" handler={Master}>
        <Route name="dashboard" handler={Dashboard}/>
        <Route name="messages" handler={Messages}/>
        <Route name="settings" handler={Settings}/>
        <Route name="contacts" handler={Contacts}/>
        <Route name="logout"/>
        <DefaultRoute handler={Messages}/>
    </Route>
);

module.exports = AppRoutes;
