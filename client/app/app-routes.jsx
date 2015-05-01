import React  from 'react';
import Router, {Route, Redirect, DefaultRoute}  from 'react-router';
import Master  from './master.jsx';
import Messages from './components/messages/messages.cjsx';
import Outcoming from './components/messages/outcoming.cjsx';
import AllMessages from './components/messages/allMessages.cjsx';
import Incoming from './components/messages/incoming.cjsx';
import Starred from './components/messages/starred.cjsx';
import Settings  from './components/settings/settings.cjsx';
import Contacts  from './components/contacts/contacts.cjsx';
import Dashboard  from './components/dashboard/dashboard.cjsx';
import Login from './components/login/login-page.cjsx'

var AppRoutes = (
    <Route name="root" path="/" handler={Master}>
        <Route name="dashboard" handler={Dashboard}/>
        <Route name="messages" path="/messages"  handler={Messages}>
          <Route name="allmessages" path="/messages/all" handler={AllMessages}/> 
          <Route name="outcoming" path="/messages/outcoming" handler={Outcoming}/> 
          <Route name="incoming" path="/messages/incoming" handler={Incoming}/> 
          <Route name="starred" path="/messages/starred" handler={Starred}/> 
          <DefaultRoute handler={AllMessages}/>
        </Route>
        <Route name="settings" handler={Settings}/>
        <Route name="contacts" handler={Contacts}/>
        <Route name="login" path="/login" handler={Login}/>
        <Route name="logout" Handler={Login}/>
        <DefaultRoute handler={Messages}/>
        <Redirect from="/" to="allmessages" />
    </Route>
);

module.exports = AppRoutes;
