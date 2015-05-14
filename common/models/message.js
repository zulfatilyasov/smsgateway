var messenger = require('../../server/io/messenger.coffee')
var consts = require('./messageConstants.coffee');
var MessageHelpers = require('./messageHelpers.coffee');
var loopback = require('loopback');

module.exports = function(Message) {
    var msgHelpers = new MessageHelpers(Message);
    var checkMessageIsSent = function(messageId) {
        setTimeout(function() {
            Message.findById(messageId, function(err, message) {
                if (!err && message) {
                    if (message.status === 'sending') {
                        message.updateAttribute('status', 'failed');
                    }
                }
            });
        }, 40 * 1000);
    };

    Message.observe('after save', function(ctx, next) {
        if (!ctx.instance){
            next()
            return;
        }
        
        var userId = ctx.instance.userId;
        if (ctx.instance && ctx.isNewInstance) {
            var userId = ctx.instance.userId;
            if (ctx.instance.origin === 'web') {
                messenger.sendMessageToUserMobile(userId, ctx.instance);
                console.log('socket io emitted send-message to mobile: %s#%s', userId, ctx.instance.body);
            }

            if (ctx.instance.origin === 'mobile') {
                messenger.sendMessageToUserWeb(userId, ctx.instance);
                console.log('socket io emitted send-message to web: %s#%s', userId, ctx.instance.body);
            }
        }

        if (ctx.instance && !ctx.isNewInstance) {
            messenger.updateUserMessageOnWeb(userId, ctx.instance);
            console.log('socket io emitted update-message to web: %s#%s', userId, ctx.instance.body);
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

    Message.deleteMany = function(ids, cb) {
        var ctx, err, query, token;
        ctx = loopback.getCurrentContext();
        token = ctx && ctx.get('accessToken');
        if (!(token && token.userId)) {
            err = new Error('not authorized');
            err.statusCode = 401;
            err.code = 'LOGIN_FAILED';
            return cb(err);
        } else {
            query = {
                id: {
                    inq: ids
                },
                userId: token.userId
            };

            return Message.destroyAll(query, function(err, info) {
                console.log(info);
                if (err) {
                    return cb(err);
                } else {
                    return cb(null);
                }
            });
        }
    };

    Message.remoteMethod('deleteMany', {
        accepts: {
            arg: 'ids',
            type: 'array'
        },
        http: {
            path: '/delete_many',
            verb: 'post'
        }
    });

    Message.resend = function(ids, cb) {
        msgHelpers.getUserMessagesByIds(ids, function(err, oldMessages) {
            if (err) {
                console.log(err);
                cb(err);
            } else {
                msgHelpers.resendMessages(oldMessages, function(err, newMessages) {
                    if (err) {
                        console.log(err)
                        cb(err)
                    } else {
                        cb(null, newMessages);
                    }
                });
            }
        });
    };

    Message.remoteMethod('resend', {
        accepts: {
            arg: 'ids',
            type: 'array'
        },
        http: {
            path: '/resend',
            verb: 'post'
        },
        returns: {
            arg: 'messages',
            type: 'array'
        }
    });

    Message.cancel = function(ids, cb) {
        msgHelpers.setCancelled(ids, cb);
    };

    Message.remoteMethod('cancel', {
        accepts: {
            arg: 'ids',
            type: 'array'
        },
        http: {
            path: '/cancel',
            verb: 'post'
        },
        returns: {
            arg: 'messages',
            type: 'array'
        }
    });

    Message.sendQueued = function (userId) {
        console.log('sending queued');
        msgHelpers.getUserMessagesByStatus(userId, 'queued', function (err, messages) {
            console.log(messages);
            if (err) {
                console.log(err);
                cb(err);
            } else {
                for (var i = messages.length - 1; i >= 0; i--) {
                    messenger.sendMessageToUserMobile(messages[i].userId, messages[i]); 
                }
            }
        });
    };
};
