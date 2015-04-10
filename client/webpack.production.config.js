var webpack = require('webpack');
var path = require('path');

module.exports = {
    context: __dirname,
    entry: [
        './app/app'
    ],
    output: {
        path: path.join(__dirname, 'build'),
        filename: '[name].js',
        publicPath: '/scripts/'
    },
    plugins: [
    ],
    module: {
        loaders: [{
            test: /\.jsx$/,
            loaders: ['react-hot', 'jsx-loader?harmony&insertPragma=React.DOM']
        }, {
            test: /\.es6$/,
            exclude: /node_modules/,
            loader: 'babel-loader'
        }, {
            test: /\.css$/,
            loader: 'style!url-loader!css'
        }, {
            test: /\.less$/,
            loader: "style!css!less"
        }, {
            test: /\.(woff|ttf|eot|svg|png)$/,
            loader: 'url-loader?limit=8192'
        }]
    },
    resolve: {
        extensions: ['', '.js', '.es6', '.jsx', '.css'],
        alias: {
            actions: __dirname + '/app/actions',
            constants: __dirname + '/app/constants',
            stores: __dirname + '/app/stores'
        }
    }
};
