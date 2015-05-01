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
            selectedIndex={this._getSelectedIndex()} 
            onItemClick={this._onMenuItemClick} />
        </div>
        <div style={contentStyle} className="secondary-content">
          <RouteHandler />
        </div>
      </div>
    );
  },

  _getSelectedIndex: function() {
    var menuItems = this.props.menuItems,
      currentItem;

    for (var i = menuItems.length - 1; i >= 0; i--) {
      currentItem = menuItems[i];
      if (currentItem.route && this.context.router.isActive(currentItem.route)) return i;
    };
  },

  getInitialState: function() {
    var pageHeaderHeight = 165;
    var viewportHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
    return {
      contentHeight: viewportHeight - pageHeaderHeight
    };
  },

  _onMenuItemClick: function(e, index, item) {
    this.context.router.transitionTo(item.route);
  }
  
});

module.exports = PageWithNav;