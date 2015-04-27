var webpack = require('webpack');
var WebpackDevServer = require('webpack-dev-server');
var config = require('./webpack.config');
var request = require('request');

var apiUrl = 'http://192.168.0.2:3200';
var app = new WebpackDevServer(webpack(config), {
    publicPath: config.output.publicPath,
    hot: true,
    historyApiFallback: true,
    proxy: {
        "/api*": "http://192.168.0.2:3200"
    }
});

// app.use('/api', function(req, res) {
//     console.log(req.url);
//     var url = apiUrl + '/api' + req.url;
//     req.pipe(request(url)).pipe(res);
// });

var port = 3000;
app.listen(port, 'localhost', function(err, result) {
    if (err) {
        console.log(err);
    }

    console.log('Listening at localhost:' + port);
});
