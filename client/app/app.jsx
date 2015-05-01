import muiStyles from './custom.less'
import appStyles from './app.styl'
import injectTapEventPlugin from "react-tap-event-plugin";
import routeActions  from './actions/RouteActions.coffee'
import userStore from './stores/UserStore.coffee'

var React = require('react'),
    Router = require('react-router'),
    router = require('./router.coffee'),
    AppRoutes = require('./app-routes.jsx');

injectTapEventPlugin();

router.run(function (Handler, state) {
    routeActions.checkPermissions(state);
    React.render(<Handler/>, document.body)
});
