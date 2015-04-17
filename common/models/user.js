var path = require('path');

module.exports = function (User) {
    //send verification email after registration
    User.afterRemote('create', function (context, user, next) {
        console.log('> user.afterRemote triggered');
        var appSettings = User.app.locals.settings;

        var options = {
            text:'{href}',
            type: 'email',
            host: appSettings.domain,
            port: appSettings.domainPort,
            to: user.email,
            from: 'noreply@zulfat.net',
            subject: 'Thanks for registering.',
            template: path.resolve(__dirname, '../../server/views/verify.ejs'),
            redirect: '/?name=' + user.name,
            user: user
        };

        user.verify(options, function (err, response) {
            if (err) {
                console.log(err);
                next(err);
                return;
            }

            next(null);

            console.log('> verification email sent:', response);
            //context.res.render('response', {
            //    title: 'Signed up successfully',
            //    content: 'Please check your email and click on the verification link before logging in.',
            //    redirectTo: '/',
            //    redirectToLinkText: 'Log in'
            //});
        });
    });

    //send password reset link when requested
    User.on('resetPasswordRequest', function (info) {
        var url = 'http://' + config.host + ':' + config.port + '/reset-password';
        var html = 'Click <a href="' + url + '?access_token=' + info.accessToken.id
            + '">here</a> to reset your password';

        User.app.models.Email.send({
            to: info.email,
            from: info.email,
            subject: 'Password reset',
            html: html
        }, function (err) {
            if (err) return console.log('> error sending password reset email');
            console.log('> sending password reset email to:', info.email);
        });
    });
};