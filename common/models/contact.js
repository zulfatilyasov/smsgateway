var _ = require('lodash');
var ObjectId = require('mongodb').ObjectId;

module.exports = function(Contact) {
    Contact.observe('after save', function(ctx, next) {
        var contact = ctx.instance;
        if (!contact || !contact.groups || !contact.groups.length) {
            next()
            return;
        }

        var userId = contact.userId;
        var groups = contact.groups;
        var groupIds = _.pluck(groups, 'id');
        var groupObjectIds = _.map(groupIds, function(stringId) {
            return new ObjectId(stringId);
        });
        if (!groupIds || !groupIds.length) {
            var err = new Error("Contact groups should have group ids");
            err.statusCode = 422;
            next(err);
            return;
        }
        var db = Contact.dataSource.connector.db;
        var GroupCollection = db.collection("Group");
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

    Contact.deleteMany = function(ids, cb) {
        Contact.find({
            where: {
                id: {
                    inq: ids
                }
            }
        }, function(err, contacts) {
            if (err) {
                cb(err);
            } else {
                cb(null);
            }
            var contactIds = _.pluck(contacts, 'id');
            var groupIds = [];
            for (var i = contacts.length - 1; i >= 0; i--) {
                groupIds = groupIds.concat(_.pluck(contacts[i].groups, 'id'));
            }
            var groupObjectIds = _.map(groupIds, function(stringId) {
                return new ObjectId(stringId);
            });
            var db = Contact.dataSource.connector.db;
            var GroupCollection = db.collection('Group');
            Contact.destroyAll({
                where: {
                    id: {
                        inq: ids
                    }
                }
            }, function(err, info) {
                if (err) {
                    cb(err);
                } else {
                    cb(null);
                }
                GroupCollection.update({
                    _id: {
                        "$in": groupObjectIds
                    }
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
