var _ = require('lodash');
var ObjectId = require('mongodb').ObjectId;
var loopback = require('loopback');

function notAutorizedError() {
    var err = new Error('not authenticated');
    err.statusCode = 401;
    return err;
}

module.exports = function(Contact) {
    Contact.observe('after save', function(ctx, next) {
        var contact = ctx.instance;
        if (!contact) {
            next()
            return;
        }

        var userId = contact.userId;
        var groups = contact.groups;
        var groupIds = _.pluck(groups, 'id');
        var groupObjectIds = _.map(groupIds, function(stringId) {
            return new ObjectId(stringId);
        });
        var GroupCollection = Contact.dataSource.connector.db.collection("Group");

        GroupCollection.update({
            _id: {
                "$in": groupObjectIds
            }
        }, {
            "$addToSet": {
                "contacts": contact.id
            }
        }, {
            multi: true
        }, function(err, info) {
            if (err) {
                next(err);
                return;
            }

            GroupCollection.find({
                "contacts": contact.id,
                _id: {
                    "$nin": groupObjectIds
                }
            }).toArray(function(err, groups) {
                console.log(groups);
                if (err) {
                    next(err);
                    return;
                }

                var ids = _.pluck(groups, '_id');
                if (!ids.length) {
                    next(null);
                    return;
                }

                GroupCollection.update({
                    _id: {
                        "$in": ids
                    }
                }, {
                    "$pull": {
                        "contacts": contact.id
                    }
                }, {
                    multi: true
                }, function(err, info) {
                    if (err) {
                        next(err);
                        return;
                    }

                    next(null);
                });
            });
        });
    });

    Contact.addressList = function(cb) {
        var Group = Contact.app.models.Group;
        var addresses = [];
        var ctx = loopback.getCurrentContext();
        var token = ctx && ctx.get('accessToken');
        if (!token || !token.userId) {
            cb(notAutorizedError())
            return;
        }
        var userId = token.userId;

        Group.find({
            filter: {
                id: true,
                name: true
            },
            where: {
                userId: userId
            }
        }, function(err, groups) {
            if (err) {
                cb(err);
                return;
            }
            var groupsMapped = _.map(groups, function(g) {
                return {
                    value: g.id,
                    label: g.name,
                    id: g.id,
                    isGroup: true
                };
            });
            addresses = groupsMapped;
            Contact.find({
                fields: {
                    name: true,
                    id: true,
                    phone: true,
                    email: true
                },
                limit: 3000,
                where: {
                    userId: userId
                }
            }, function(err, contacts) {
                if (err) {
                    cb(err);
                    return;
                }
                var contactsMapped = _.map(contacts, function(c) {
                    return {
                        label: c.name,
                        value: c.phone || c.email,
                        id: c.id,
                        isContact: true
                    };
                });
                addresses = addresses.concat(contactsMapped);
                cb(null, addresses);
            });
        });
    };

    Contact.remoteMethod('addressList', {
        returns: {
            arg: 'addresses',
            type: 'array'
        },
        http: {
            path: '/addresslist',
            verb: 'get'
        }
    });



    Contact.updateMany = function(contacts, cb) {
        var ctx = loopback.getCurrentContext();
        var token = ctx && ctx.get('accessToken');
        if (!token || !token.userId) {
            cb(notAutorizedError());
            return;
        }

        var updatedCount = 0;
        for (var i = contacts.length - 1; i >= 0; i--) {
            if (!token.userId === contacts[i].userId) {
                cb(notAutorizedError());
                return;
            }
            Contact.upsert(contacts[i], function(err, info) {
                if (err) {
                    cb(err);
                    return;
                } else {
                    updatedCount++;
                    if (updatedCount === contacts.length) {
                        cb(null);
                    }
                }
            });
        };
    }

    Contact.remoteMethod('updateMany', {
        accepts: {
            arg: 'contacts',
            type: 'array'
        },
        http: {
            path: '/updateMany',
            verb: 'post'
        }
    });


    Contact.deleteMany = function(ids, cb) {
        var ctx = loopback.getCurrentContext();
        var token = ctx && ctx.get('accessToken');
        if (!token || !token.userId) {
            cb(notAutorizedError())
            return;
        }
        var userId = token.userId;

        Contact.find({
            where: {
                id: {
                    inq: ids
                },
                userId: userId
            }
        }, function(err, contacts) {
            if (err) {
                cb(err);
                return;
            }
            if (!contacts || !contacts.length) {
                var err = new Error('contacts not found');
                err.statusCode = 404;
                cb(err);
                return;
            }
            var contactIds = _.pluck(contacts, 'id');
            var groupIds = [];
            for (var i = contacts.length - 1; i >= 0; i--) {
                groupIds = groupIds.concat(_.pluck(contacts[i].groups, 'id'));
            }
            var groupObjectIds = _.map(groupIds, function(stringId) {
                return new ObjectId(stringId);
            });
            var GroupCollection = Contact.dataSource.connector.db.collection('Group');
            Contact.destroyAll({
                id: {
                    inq: ids
                },
                userId: userId
            }, function(err, info) {
                if (err) {
                    cb(err);
                    return;
                }
                GroupCollection.update({
                    _id: {
                        "$in": groupObjectIds
                    },
                    userId: userId
                }, {
                    "$pullAll": {
                        "contacts": contactIds
                    }
                }, function(err, info) {
                    if (err) {
                        cb(err);
                    } else {
                        cb(null);
                    }
                });
            });
        });
    };

    Contact.remoteMethod('deleteMany', {
        accepts: {
            arg: 'ids',
            type: 'array'
        },
        http: {
            path: '/deleteMany',
            verb: 'post'
        }
    });

    Contact.observe('before delete', function(ctx, next) {
        if (!ctx.instance) {
            next();
            return
        }
        var contactId = contactId;
        var groupIds = _.pluck(ctx.instance.groups, 'id');
        var groupObjectIds = _.map(groupIds, function(stringId) {
            return new ObjectId(stringId);
        });
        var db = Contact.dataSource.connector.db;
        var GroupCollection = db.collection("Group");
        GroupCollection.update({
                _id: {
                    "$in": groupObjectIds
                }
            }, {
                "$pull": {
                    "contacts": contact.id
                }
            }, {
                multi: true
            },
            function(err, info) {
                if (err) {
                    next(err);
                } else {
                    next(null);
                }
            }
        );
    });
};
