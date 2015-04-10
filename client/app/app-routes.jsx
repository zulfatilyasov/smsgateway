var React = require('react');
var Router = require('react-router');
var Route = Router.Route;
var Redirect = Router.Redirect;
var DefaultRoute = Router.DefaultRoute;
var Master = require('./master.jsx');
var Messages = require('./components/messages.jsx');
var Settings = require('./components/settings.jsx');
var Contacts = require('./components/contacts.jsx');
var Dashboard = require('./components/dashboard.jsx');

var AppRoutes = (
  <Route name="root" path="/" handler={Master}>
    <Route name="dashboard" handler={Dashboard} />
    <Route name="messages" handler={Messages} />
    <Route name="settings" handler={Settings} />
    <Route name="contacts" handler={Contacts} />
    <DefaultRoute handler={Messages}/>
  </Route>
);

module.exports = AppRoutes;
