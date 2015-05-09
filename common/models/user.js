var path = require('path');
var loopback = require('loopback');
var messenger = require('../../server/io/messenger.coffee')

module.exports = function(User) {
    User.afterRemote('create', function(context, user, next) {
        console.log('> user.afterRemote triggered');
        var appSettings = User.app.locals.settings;

        var options = {
            text: '{href}',
            type: 'email',
            host: appSettings.domain,
            port: appSettings.domainPort,
            to: user.email,
            from: appSettings.emailFrom,
            subject: 'Thanks for registering.',
            template: path.resolve(__dirname, '../../server/views/verify.ejs'),
            redirect: '/?name=' + user.name,
            user: user
        };

        user.verify(options, function(err, response) {
            if (err) {
                console.log(err);
                next(err);
                return;
            }

            console.log('> verification email sent:', response);
            next(null);

            //context.res.render('response', {
            //    title: 'Signed up successfully',
            //    content: 'Please check your email and click on the verification link before logging in.',
            //    redirectTo: '/',
            //    redirectToLinkText: 'Log in'
            //});
        });
    });

    User.requestResetPassword = function(email, cb) {
        User.resetPassword({
            email: email
        }, function(err, info) {
            console.log(arguments);
            console.log('requestResetPassword ' + email);
            if (err) {
                cb(err, null);
            } else {
                cb(null);
            }
        });
    };

    User.remoteMethod(
        'requestResetPassword', {
            accepts: {
                arg: 'email',
                type: 'string'
            },
            http: {
                path: '/request_reset_password',
                verb: 'post'
            }
        }
    );

    User.devices = function(cb) {
        var ctx = loopback.getCurrentContext();
        var token = ctx && ctx.get('accessToken');
        if (!token || !token.userId) {
            cb('not authorized');
            return;
        }

        messenger.getUserDevice(token.userId, function(err, deviceModel) {
            if (err) {
                cb(err);
                return
            }
            if (deviceModel) {
                cb(null, deviceModel);
            } else {
                cb(null, null);
            }
        });
    };

    User.remoteMethod(
        'devices', {
            returns: {
                arg: 'model',
                type: 'string'
            },
            http: {
                path: '/devices',
                verb: 'get'
            }
        }
    );


    User.setPassword = function(accessToken, password, confirmation, cb) {
        console.log(arguments);

        if (!accessToken) {
            cb(new Error('unauthorized'));
        }

        if (!password || !confirmation) {
            cb(new Error('Password and confirmation required'));
        }

        if (password !== confirmation) {
            cb(new Error('Passwords do not match'));
        }
        User.app.models.AccessToken.findById(accessToken, function(err, token) {
            if (err) {
                cb(err);
            }
            if (!token || !token.userId) {
                cb(new Error('token not found'));
            }

            User.findById(token.userId, function(err, user) {
                if (err) {
                    cb(err);
                }
                user.updateAttribute('password', password, function(err, user) {
                    if (err) {
                        cb(err);
                    } else {
                        console.log('updated password successfully');
                        cb(null);
                    }
                });
            });
        })


    };

    User.remoteMethod(
        'setPassword', {
            accepts: [{
                arg: 'accessToken',
                type: 'string'
            }, {
                arg: 'password',
                type: 'string'
            }, {
                arg: 'confirmation',
                type: 'string'
            }],
            http: {
                path: '/setPassword',
                verb: 'post'
            }
        }
    );

    User.confirmResetPassword = function(access_token, redirect, cb) {
        if (!access_token) {
            cb(new Error('unauthorized'));
        } else {
            cb(null);
        }
    };

    User.remoteMethod(
        'confirmResetPassword', {
            accepts: [{
                arg: 'access_token',
                type: 'string'
            }, {
                arg: 'redirect',
                type: 'string'
            }],
            http: {
                path: '/confirm_reset_password',
                verb: 'get'
            }
        }
    );

    User.afterRemote('confirmResetPassword', function(ctx, inst, next) {
        if (ctx.args.redirect !== undefined) {
            if (!ctx.res) {
                return next(new Error('The transport does not support HTTP redirects.'));
            }
            ctx.res.location(ctx.args.redirect);
            ctx.res.status(302);
        }
        next();
    });

    User.on('resetPasswordRequest', function(info) {
        var render = loopback.template(path.join(__dirname, '..', '..', 'server', 'views', 'change-password.ejs'));
        var appSettings = User.app.locals.settings;
        var url = 'http://' + appSettings.domain + ':' + appSettings.domainPort + '/api/users/confirm_reset_password';
        url += '?access_token=' + info.accessToken.id + '&redirect=/?access_token=' + info.accessToken.id;

        var html = render({
            url: url
        });

        User.app.models.Email.send({
            to: info.email,
            from: info.email,
            subject: 'Password reset',
            html: html
        }, function(err) {
            if (err) return console.log('> error sending password reset email');
            console.log('> sending password reset email to:', info.email);
        });
    });
};
