module.exports = function(Message) {
    Message.observe('after save', function(ctx, next) {
        var io = Message.app.io;
        if (ctx.instance) {
            io.emit('send-message', ctx.instance);
            console.log('socket io emitted send-message: %s#%s', ctx.Model.modelName, ctx.instance.id);
        } else {
            console.log('Updated %s matching %j',
                ctx.Model.pluralModelName,
                ctx.where);
        }
        next();
    });

    Message.beforeRemote('create', function(ctx, message, next) {
        var ObjectId = Message.app.dataSources['Mongodb'].ObjectID;
        if(ctx.req.accessToken) {
            var userId = ctx.req.accessToken.userId;
            ctx.req.body.userId = new ObjectId(userId);
            next();
        } else {
            next(new Error('must be logged in to save message'))
        }
    });
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
