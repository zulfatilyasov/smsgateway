"use strict";

module.exports = function(app) {
    app.models().forEach(function(Model) {
        if (Model.dataSource.name !== app.dataSources.mongodb.name) {
            return;
        }
        if (hasUpdatedOnProperty(Model)) {
            Model.observe('before save', function(ctx, next) {
                var now = new Date();
                if (ctx.instance) {
                    if (!ctx.instance.id) {
                        ctx.instance.addedOn = now;
                    }
                    ctx.instance.updatedOn = now;
                } else {
                    ctx.data.updatedOn = now;
                }
                next();
            });
        }
    });

    function hasUpdatedOnProperty(Model) {
        return Model.definition && Model.definition.properties && Model.definition.properties.addedOn && Model.definition.properties.updatedOn;
    }
};
