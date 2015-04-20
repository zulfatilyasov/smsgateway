// preprocessor.js
var coffee = require('coffee-react');
var ReactTools = require('react-tools');
module.exports = {
    process: function (src, path) {
        if (path.match(/\.coffee$/) || path.match(/\.cjsx$/)) {
          return coffee.compile(src, {
              'bare': true
          });
        }
        return ReactTools.transform(src, {
            harmony: true
        });
    }
};