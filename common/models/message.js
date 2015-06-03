var messenger = require('../../server/io/messenger.coffee')
var consts = require('./messageConstants.coffee');
var MessageHelpers = require('./messageHelpers.coffee');
var loopback = require('loopback');
var _ = require('lodash');
var agenda = require('../../server/jobs/agenda.js');

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
        if (!ctx.instance) {
            next()
            return;
        }

        var userId = ctx.instance.userId;
        if (ctx.instance && ctx.isNewInstance) {
            if (ctx.instance.origin === 'web') {
                messenger.sendMessageToUserMobile(userId, ctx.instance);
            }

            if (ctx.instance.origin === 'mobile') {
                messenger.sendMessageToUserWeb(userId, ctx.instance);
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

    Message.remoteMethod('send', {
        accepts: [{
            arg: 'message',
            type: 'object'
        }, {
            arg: 'contacts',
            type: 'array'
        }, {
            arg: 'groups',
            type: 'array'
        }],

        returns: {
            arg: 'messages',
            type: 'array'
        },

        http: {
            path: '/send',
            verb: 'post'
        }
    });

    var sendMessageToContactsAndGroups = function(message, contacts, groupIds, cb) {
        var contactIds = _.map(contacts, function(c) {
            return c.id;
        });

        var Group = Message.app.models.Group;
        var Contact = Message.app.models.Contact;

        Group.find({
            fields: {
                contacts: true
            },
            where: {
                id: {
                    inq: groupIds
                }
            }
        }, function(err, groups) {
            if (err) {
                cb(err);
                return;
            }
            var groupContactIds = [];
            for (var i = groups.length - 1; i >= 0; i--) {
                groupContactIds = groupContactIds.concat(groups[i].contacts);
            };
            var allContactsIds = groupContactIds.concat(contactIds);
            Contact.find({
                where: {
                    id: {
                        inq: allContactsIds
                    }
                }
            }, function(err, recipients) {
                if (err) {
                    cb(err);
                    return;
                }

                var newMessages = _.map(recipients, function(recipient) {
                    var msg = _.cloneDeep(message);
                    msg.address = recipient.phone;
                    return msg
                });

                Message.create(newMessages, function(err, result) {
                    if (err) {
                        cb(err)
                        return;
                    }
                    cb(null, result);
                });
            });
        });
    }

    function saveScheduled(message, cb) {
        if (!message.sendDate) {
            var error = new Error('Scheduled message should have send date');
            error.statusCode = 401;
            cb(err);
            return;
        }

        Message.create(message, function(err, message) {
            if (err) {
                cb(err);
                return;
            }

            agenda.schedule(message.sendDate, 'send message', {
                id: message.id
            });

            cb(message);
        });
    }

    Message.createContactsAndSend = function(message, contacts, groups, cb) {
        var newContacts = _.filter(contacts, {
            id: null
        });

        var existingContacts = _.filter(contacts, function(c) {
            return !!c.id;
        });

        var groupIds = _.pluck(groups, 'id');
        var Contact = Message.app.models.Contact;

        if (newContacts.length) {
            Contact.create(newContacts, function(err, createdContacts) {
                if (err) {
                    cb(err);
                    return;
                }
                var contacts = existingContacts.concat(createdContacts);
                sendMessageToContactsAndGroups(message, contacts, groupIds, cb);
            });
        } else {
            sendMessageToContactsAndGroups(message, contacts, groupIds, cb);
        }
    }

    Message.send = function(message, contacts, groups, cb) {
        if (message.status === 'scheduled') {
            message.address = {
                contacts: contacts,
                groups: groups
            };
            saveScheduled(message, cb);
        } else {
            Message.createContactsAndSend(message, contacts, groups, cb);
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

    Message.sendQueued = function(userId) {
        console.log('sending queued');
        msgHelpers.getUserMessagesByStatus(userId, 'queued', function(err, messages) {
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
