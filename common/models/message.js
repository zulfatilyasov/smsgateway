var messenger = require('../../server/io/messenger.coffee')
var consts = require('./messageConstants.coffee');
var MessageHelpers = require('./messageHelpers.coffee');

module.exports = function(Message) {
    var msgHelpers = new MessageHelpers(Message);
    var checkMessageIsSent = function (messageId) {
        setTimeout(function () {
            Message.findById(messageId, function (err, message) {
                if(!err && message){
                    if(message.status === 'sending') {
                        message.updateAttribute('status', 'failed');
                    }
                }
            });
        }, 40 * 1000);
    };

    Message.observe('after save', function(ctx, next) {
        if (ctx.instance && ctx.isNewInstance) {
            if (ctx.instance.origin === 'web') {
                messenger.sendMessageToUserMobile(ctx.instance.userId, ctx.instance);
                checkMessageIsSent(ctx.instance.id);
                console.log('socket io emitted send-message to mobile: %s#%s', ctx.instance.userId, ctx.instance.body);
            }

            if (ctx.instance.origin === 'mobile') {
                messenger.sendMessageToUserWeb(ctx.instance.userId, ctx.instance);
                console.log('socket io emitted send-message to web: %s#%s', ctx.instance.userId, ctx.instance.body);
            }
        }

        if (ctx.instance && !ctx.isNewInstance) {
            messenger.updateUserMessageOnWeb(ctx.instance.userId, ctx.instance);
            console.log('socket io emitted update-message to web: %s#%s', ctx.instance.userId, ctx.instance.body);
        }
        next();
    });

    Message.beforeRemote('create', function(ctx, message, next) {
        var ObjectId = Message.app.dataSources['Mongodb'].ObjectID;
        if (ctx.req.accessToken) {
            var userId = ctx.req.accessToken.userId;
            ctx.req.body.userId = new ObjectId(userId);
            next();
        } else {
            next(new Error('must be logged in to save message'))
        }
    });
};
