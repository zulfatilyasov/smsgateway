var webpack = require('webpack');
var path = require('path');

module.exports = {
    context: __dirname,
    entry: [
        'webpack-dev-server/client?http://localhost:3000',
        'webpack/hot/only-dev-server',
        './app/app'
    ],
    output: {
        path: path.join(__dirname, 'build'),
        filename: '[name].js',
        publicPath: '/scripts/'
    },
    plugins: [
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NoErrorsPlugin()
    ],
    module: {
        postLoaders: [],
        loaders: [{
            test: /\.jsx$/,
            exclude: /node_modules/,
            loaders: ['react-hot', 'babel-loader?optional=runtime']
        }, {
            test: /\.es6$/,
            exclude: /node_modules/,
            loader: 'babel-loader?optional=runtime'
        }, {
            test: /\.css$/,
            loader: 'style!url-loader!css!autoprefixer'
        }, {
            test: /\.less$/,
            loader: "style!css!autoprefixer!less"
        }, {
            test: /\.(woff|ttf|eot|svg|png)$/,
            loader: 'url-loader?limit=8192'
        }, {
            test: /\.styl$/,
            loader: 'style!css!stylus?paths=node_modules/jeet/stylus/'
        }, {
            test: /\.cjsx$/,
            loaders: ['react-hot', 'coffee', 'cjsx']
        }, {
            test: /\.coffee$/,
            loader: 'transform?envify!coffee'
        }]
    },
    resolve: {
        extensions: ['', '.js', '.es6', '.jsx', '.css', '.coffee', '.cjsx'],
        alias: {
            actions: __dirname + '/app/actions',
            constants: __dirname + '/app/constants',
            stores: __dirname + '/app/stores'
        }
    }
};
