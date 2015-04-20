// preprocessor.js
var coffee = require('coffee-react');
var ReactTools = require('react-tools');
module.exports = {
    process: function(src, path) {
        // console.log(path);
        if (path.match(/\.coffee$/) || path.match(/\.cjsx$/)) {
            return coffee.compile(src, {
                'bare': true
            });
        }

        if (/\.jsx$/.test(path) || /react-test.js$/.test(path)) {
            return ReactTools.transform(src, {
                harmony: true
            });
        }

        return src;
    }
};
