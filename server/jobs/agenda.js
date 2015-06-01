var Agenda = require('agenda');

var agenda = new Agenda({
    db: {
        address: 'localhost:27017/agenda'
    }
});

module.exports = {
    start: function(app) {
        agenda.define('send message', function(job, done) {
            var Message = app.models.Message;
            var data = job.attrs.data;
            Message.find({
                id: data.id
            }, function(err, message) {
                if (err) return done(err);
                if (!message) return done();

                var callBack = function(err, data) {
                    if (err) return done(err);

                    if (!message.repeated) {
                        Message.remove({
                            id: message.id
                        }, function(err, info) {
                            if (err) return done(err);
                            done();
                        });

                    }
                }
                Message.createContactsAndSend(message, message.address.contacts, message.address.groups, callBack);
            });
        });

        agenda.start();
    },

    agenda: agenda,

    schedule: agenda.schedule
};
