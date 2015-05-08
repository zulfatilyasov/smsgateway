var messenger = require('../../server/io/messenger.coffee')
var consts = require('./messageConstants.coffee');
var MessageHelpers = require('./messageHelpers.coffee');

module.exports = function(Message) {
    var msgHelpers = new MessageHelpers(Message);

    Message.observe('after save', function(ctx, next) {
        if (ctx.instance && ctx.isNewInstance) {
            if (ctx.instance.origin === 'web') {
                messenger.sendMessageToUserMobile(ctx.instance.userId, ctx.instance);
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

    // messenger.on(consts.MESSAGE_RECEIVED, msgHelpers.saveReceivedMessage);
    // messenger.on(consts.UPDATE_MESSAGE_STATUS, msgHelpers.updateMessageStatus);

    //
    //Message.observe('before save', function(ctx, next) {
    //    if (ctx.instance) {
    //        var accessToken = ctx.get('accessToken');
    //        console.log(accessToken);
    //        var userId = accessToken.userId;
    //        ctx.instance.userId = userId;
    //        console.log('Saved %s#%s', ctx.Model.modelName, ctx.instance.id);
    //    } else {
    //        console.log('Updated %s matching %j',
    //            ctx.Model.pluralModelName,
    //            ctx.where);
    //    }
    //    next();
    //});
};
