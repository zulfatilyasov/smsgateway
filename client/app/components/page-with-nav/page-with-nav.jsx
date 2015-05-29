var React = require('react'),
  Router = require('react-router'),
  RouteHandler = Router.RouteHandler,
  mui = require('material-ui'),
  Menu = mui.Menu;

var PageWithNav = React.createClass({

  mixins: [Router.Navigation, Router.State],

  propTypes: {
    menuItems: React.PropTypes.array
  },
  componentDidMount: function() {
    $(".secondary-nav").scrollToFixed();
  },

  render: function() {
    var contentStyle = {minHeight:this.state.contentHeight}

    return (
      <div className="page-with-nav">
        <div className="secondary-nav">
          <Menu 
            ref="menuItems" 
            zDepth={0} 
            autoWidth={false}
            menuItems={this.props.menuItems} 
            selectedIndex={this.props.selectedIndex()} 
            onItemTap={null}
            onItemClick={this._onMenuItemClick} />
        </div>
        <div style={contentStyle} className="secondary-content">
          <div className="toobarWrap">
            {this.props.toolbar}
          </div>
          <RouteHandler />
        </div>
      </div>
    );
  },

  getInitialState: function() {
    var pageHeaderHeight = 165;
    var viewportHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
    return {
      contentHeight: viewportHeight - pageHeaderHeight
    };
  },

  _onMenuItemClick: function(e, index, item) {
    e.preventDefault();
    if(item.route){
      this.context.router.transitionTo(item.route, item.params);
    }
    this.props.onMenuItemClick(item);
  }
  
});

module.exports = PageWithNav;