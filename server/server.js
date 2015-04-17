var loopback = require('loopback');
var boot = require('loopback-boot');
var path = require('path');

var app = module.exports = loopback();

app.start = function() {
    // start the web server
    return app.listen(function() {
        app.emit('started');
        console.log('Web server listening at: %s', app.get('url'));
    });
};

app.use(loopback.logger('dev'));

app.use(loopback.static(path.join(__dirname, '..', 'client', 'build')));

boot(app, __dirname, function(err) {
    if (err) throw err;

    if (require.main === module) {
        app.io = require('socket.io')(app.start());
        app.io.on('connection', function(socket) {
            console.log('user connected');
        });
    }
});
