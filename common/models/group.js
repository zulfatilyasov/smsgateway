var q = require('Q');

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

    Group.observe('before delete', function(ctx, next) {
        var group = ctx.instance;

        var db = Group.dataSource.connector.db;
        var ContactCollection = db.collection("Contact");
        
        ContactCollection.update({
            "groups.id": group.id.toString()
        }, {
            "$pull": {
                "groups":{
                   id:group.id.toString() 
                } 
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


    Group.contacts = function(id, cb) {
        Group.findById(id, function(err, group) {
            if (err) {
                cb(err);
                return
            }

            if(!group) {
                var err = new Error('group not found')
                err.statusCode = 404;
                cb(err)
                return;
            }

            var Contact = Group.app.models.Contact;
            console.log(group.contacts);
            Contact.find({
                where: {
                    id: {
                        inq: group.contacts
                    }
                }
            }, function(err, contacts) {
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
