var q = require('q');
var loopback = require('loopback');

function notAutorizedError() {
    var err = new Error('not authenticated');
    err.statusCode = 401;
    return err;
}

module.exports = function(Group) {
    Group.observe('after save', function(ctx, next) {
        var group = ctx.instance;
        if (!group || group.isNewInstance) {
            next();
            return;
        }

        var db = Group.dataSource.connector.db;
        var ContactCollection = db.collection("Contact");

        ContactCollection.update({
            "groups.id": group.id.toString()
        }, {
            "$set": {
                "groups.$.name": group.name
            }
        }, {
            multi: true
        }, function(err, info) {
            if (err) {
                next(err);
            } else {
                next(null);
            }
        });
    });


    Group.beforeRemote('create', function(ctx, message, next) {
        var ObjectId = Group.app.dataSources['Mongodb'].ObjectID;
        if (ctx.req.accessToken) {
            var userId = ctx.req.accessToken.userId;
            ctx.req.body.userId = new ObjectId(userId);
            next();
        } else {
            next(notAutorizedError());
        }
    });

    Group.updateMany = function(groups, cb) {
        var ctx = loopback.getCurrentContext();
        var token = ctx && ctx.get('accessToken');
        if (!token || !token.userId) {
            cb(notAutorizedError());
            return;
        }

        var updatedCount = 0;
        for (var i = groups.length - 1; i >= 0; i--) {
            if (!token.userId === groups[i].userId) {
                cb(notAutorizedError());
                return;
            }
            Group.upsert(groups[i], function(err, info) {
                if (err) {
                    cb(err);
                } else {
                    updatedCount++;
                    if (updatedCount === groups.length) {
                        cb(null);
                    }
                }
            });
        };
    };

    Group.remoteMethod('updateMany', {
        accepts: {
            arg: 'groups',
            type: 'array'
        },
        http: {
            path: '/updateMany',
            verb: 'post'
        }
    });

    Group.remoteMethod('deleteGroup', {
        accepts: [{
            arg: 'id',
            type: 'string'
        }, {
            arg: 'deleteContacts',
            type: 'boolean'
        }],
        http: {
            path: '/deleteGroup',
            verb: 'post'
        }
    });

    function deleteGroupById(id, cb) {
        Group.destroyById(id, function(err, info) {
            if (err) return cb(err);
            deleteGroupFromContacts(id, cb);
        });
    }

    Group.deleteGroup = function(id, deleteContacts, cb) {
        var ctx = loopback.getCurrentContext();
        var token = ctx && ctx.get('accessToken');
        if (!token || !token.userId) {
            cb(notAutorizedError());
            return;
        }

        if (deleteContacts) {
            var ContactCollection = Group.dataSource.connector.db.collection("Contact");
            ContactCollection.remove({
                'groups': {
                    '$size': 1
                },
                'groups.id': id
            }, function(err, info) {
                if (err) return cb(err);
                deleteGroupById(id, cb);
            });
        } else {
            deleteGroupById(id, cb);
        }
    }

    function deleteGroupFromContacts(groupId, cb) {
        var db = Group.dataSource.connector.db;
        var ContactCollection = db.collection("Contact");

        ContactCollection.update({
            "groups.id": groupId
        }, {
            "$pull": {
                "groups": {
                    id: groupId
                }
            }
        }, {
            multi: true
        }, function(err, info) {
            if (err) {
                cb(err);
            } else {
                cb(null);
            }
        });
    }

    Group.observe('before delete', function(ctx, next) {
        var group = ctx.instance;
        if (!group || !group.id) {
            next();
            return;
        }

        deleteGroupFromContacts(group.id.toString(), next);
    });


    Group.contacts = function(id, limit, skip, cb) {
        Group.findById(id, function(err, group) {
            if (err) {
                cb(err);
                return
            }

            if (!group) {
                var err = new Error('group not found')
                err.statusCode = 404;
                cb(err)
                return;
            }

            var Contact = Group.app.models.Contact;

            var filter = {
                order: 'id DESC',
                where: {
                    id: {
                        inq: group.contacts
                    }
                }
            };

            if (limit)
                filter.limit = parseInt(limit);

            if (skip)
                filter.skip = parseInt(skip);

            Contact.find(filter, function(err, contacts) {
                if (err) {
                    cb(err);
                    return;
                }
                cb(null, contacts);
            });
        });
    };

    Group.remoteMethod(
        'contacts', {
            accepts: [{
                arg: 'id',
                type: 'string',
                required: true
            }, {
                arg: 'limit',
                type: 'number',
                required: false
            }, {
                arg: 'skip',
                type: 'number',
                required: false
            }],
            http: {
                path: '/:id/contacts',
                verb: 'get'
            },
            returns: {
                arg: 'contacts',
                type: 'array'
            }
        }
    );
};
