    var webpack = require('webpack');
    var path = require('path');

    module.exports = {
        context: __dirname,
        entry: [
            './client/app/app'
        ],
        output: {
            path: path.join(__dirname, 'client', 'build'),
            filename: '[name].js',
            publicPath: '/client/scripts/'
        },
        plugins: [
            new webpack.optimize.UglifyJsPlugin({
                compress: {
                    warnings: false
                }
            })
        ],
        module: {
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
                loader: 'style!css!autoprefixer!stylus?paths=node_modules/jeet/stylus/'
            }, {
                test: /\.cjsx$/,
                loaders: ['react-hot', 'coffee', 'cjsx']
            }, {
                test: /\.coffee$/,
                loader: 'transform?envify!coffee'
            }]
        },
        resolve: {
            extensions: ['', '.js', '.es6', '.jsx', '.css'],
            alias: {
                actions: __dirname + '/client/app/actions',
                constants: __dirname + '/client/app/constants',
                stores: __dirname + '/client/app/stores'
            }
        }
    };
