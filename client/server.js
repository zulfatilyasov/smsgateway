var webpack = require('webpack');
var WebpackDevServer = require('webpack-dev-server');
var config = require('./webpack.config');

var app = new WebpackDevServer(webpack(config), {
    publicPath: config.output.publicPath,
    hot: true,
    historyApiFallback: true
});
app.use(function(req, res) {
    console.log(req.url);
});
var port = 3500;
app.listen(port, 'localhost', function (err, result) {
    if (err) {
        console.log(err);
    }

    console.log('Listening at localhost:' + port);
});