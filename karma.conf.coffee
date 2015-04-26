# Karma configuration
# Generated on Thu Apr 23 2015 12:52:22 GMT+0300 (MSK)

module.exports = (config) ->
  config.set

    # base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: ''


    # frameworks to use
    # available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine']


    # list of files / patterns to load in the browser
    files: [
        'server/**/*_test.js',
        'client/app/**/*_test.js'
    ],

    preprocessors: {
        'server/**/*_test.js': ['webpack','sourcemap'],
        'client/app/**/*_test.js': ['webpack','sourcemap']
    },

    # files: [
    #   'tests.webpack.js'
    # ],

    # preprocessors: {
    #   'tests.webpack.js': [ 'webpack', 'sourcemap' ]
    # },

    reporters: ['progress', 'dots' ],

    webpack: {
      devtool: 'inline-source-map',
      module: {
        loaders: [{
            test: /\.(js|jsx)$/,
            exclude: /node_modules/,
            loaders: ['babel-loader?optional=runtime']
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
            loaders: ['coffee', 'cjsx']
        }, {
            test: /\.coffee$/,
            loader: 'coffee'
        }]
      }
    },

    webpackServer: {
      noInfo: true
    },

    # list of files to exclude
    exclude: [
    ]


    # test results reporter to use
    # possible values: 'dots', 'progress'
    # available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress']


    # web server port
    port: 9876


    # enable / disable colors in the output (reporters and logs)
    colors: true


    # level of logging
    # possible values:
    # - config.LOG_DISABLE
    # - config.LOG_ERROR
    # - config.LOG_WARN
    # - config.LOG_INFO
    # - config.LOG_DEBUG
    logLevel: config.LOG_INFO


    # enable / disable watching file and executing tests whenever any file changes
    autoWatch: true


    # start these browsers
    # available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome']


    # Continuous Integration mode
    # if true, Karma captures browsers, runs the tests and exits
    singleRun: false
