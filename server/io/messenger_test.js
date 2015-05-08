describe('Socket io messenger', function() {
    var ioConstants = require('../../common/constants/ioConstants.coffee');
    var messageConsts = require('../../common/models/messageConstants.coffee');

    var proxyquire = require('proxyquire');
    var fakeRedisDb = jasmine.createSpyObj('fakeRedisDb', ['hget', 'hset']);

    var fakeUserId = '123';
    var fakeClientId = '312';
    var fakeAccessTokenId = 'qwe';
    var notFoundError = 'not found';
    var message = {
        body: 'hello world',
        address: '+79274568767'
    };

    var fakeToken = {
        id: fakeAccessTokenId,
        userId: fakeUserId
    };

    fakeRedisDb.hget.andCallFake(function(hashkey, prop, callback) {
        callback(null, fakeClientId);
    });

    fakeRedisDb.hset.andCallFake(function(hashkey, prop, val, callback) {
        callback();
    });

    var redisStub = {
        createClient: function() {
            return fakeRedisDb;
        }
    }

    var messenger = proxyquire('./messenger.coffee', {
        'redis': redisStub
    });

    var fakeEmit = jasmine.createSpy('emit');

    var fakeFindById = jasmine.createSpy('findById').andCallFake(function(id, callback) {
        if (id == fakeAccessTokenId) {
            callback(null, fakeToken);
        } else {
            callback(notFoundError);
        }
    });

    var app = {
        io: {
            use: jasmine.createSpy('use'),
            on: jasmine.createSpy('on'),
            to: jasmine.createSpy('to').andCallFake(function() {
                return {
                    emit: fakeEmit
                }
            }),
        },
        models: {
            AccessToken: {
                findById: fakeFindById
            }
        }

    };

    beforeEach(function() {
        messenger.initialize(app);
    });

    it('should register auth middleware and allow connections after initialize', function() {
        expect(messenger.io.use).toHaveBeenCalled();
        expect(messenger.io.on).toHaveBeenCalledWith('connection', jasmine.any(Function));
    });

    it('should save connected clientId to redis', function() {
        var next = jasmine.createSpy('next');
        var origin
        messenger.registerClient(fakeAccessTokenId, origin, fakeClientId, next);

        expect(fakeFindById).toHaveBeenCalledWith(fakeAccessTokenId, jasmine.any(Function));
        expect(fakeRedisDb.hset).toHaveBeenCalledWith(fakeUserId, origin, fakeClientId, jasmine.any(Function))
        expect(next).toHaveBeenCalled();

        var wrongToken = 'this token doesnt exist'
        messenger.registerClient(wrongToken, origin, fakeClientId, next);
        expect(fakeFindById).toHaveBeenCalledWith(wrongToken, jasmine.any(Function));
        expect(next).toHaveBeenCalledWith(notFoundError);
    });

    it('should send message', function() {
        expect(messenger.sendMessageToUserMobile).toBeDefined();

        spyOn(messenger, 'sendMessageToClient').andCallThrough();
        spyOn(messenger, 'getMobileClientIdForUser').andCallThrough();
        messenger.sendMessageToUserMobile(fakeUserId, message);

        expect(fakeRedisDb.hget).toHaveBeenCalledWith(jasmine.any(String), jasmine.any(String), jasmine.any(Function));
        expect(messenger.getMobileClientIdForUser).toHaveBeenCalledWith(fakeUserId, jasmine.any(Function));
        expect(messenger.sendMessageToClient).toHaveBeenCalledWith(fakeClientId, message);
        expect(messenger.io.to).toHaveBeenCalledWith(fakeClientId);
        expect(fakeEmit).toHaveBeenCalledWith(ioConstants.SEND_MESSAGE, message);
    });

    it('should send message to web', function() {
        expect(messenger.sendMessageToUserWeb).toBeDefined();

        spyOn(messenger, 'sendMessageToClient').andCallThrough();
        spyOn(messenger, 'getWebClientIdForUser').andCallThrough();
        messenger.sendMessageToUserWeb(fakeUserId, message);

        expect(fakeRedisDb.hget).toHaveBeenCalledWith(fakeUserId, 'web', jasmine.any(Function));
        expect(messenger.getWebClientIdForUser).toHaveBeenCalledWith(fakeUserId, jasmine.any(Function));
        expect(messenger.sendMessageToClient).toHaveBeenCalledWith(fakeClientId, message);
        expect(messenger.io.to).toHaveBeenCalledWith(fakeClientId);
        expect(fakeEmit).toHaveBeenCalledWith(ioConstants.SEND_MESSAGE, message);
    });

    it('should register callback to event', function() {
        var messageId ='messageId';
        messenger.on(messageId, function () {});
        expect(messenger.io.on).toHaveBeenCalledWith(messageId, jasmine.any(Function));
    });

    it('should update message status', function() {
        expect(messenger.updateUserMessageOnWeb).toBeDefined();

        spyOn(messenger, 'updateMessageOnClient').andCallThrough();
        spyOn(messenger, 'getWebClientIdForUser').andCallThrough();
        messenger.updateUserMessageOnWeb(fakeUserId, message);

        expect(fakeRedisDb.hget).toHaveBeenCalledWith(fakeUserId, 'web', jasmine.any(Function));
        expect(messenger.getWebClientIdForUser).toHaveBeenCalledWith(fakeUserId, jasmine.any(Function));
        expect(messenger.updateMessageOnClient).toHaveBeenCalledWith(fakeClientId, message);
        expect(messenger.io.to).toHaveBeenCalledWith(fakeClientId);
        expect(fakeEmit).toHaveBeenCalledWith(ioConstants.UPDATE_MESSAGE, message);
    });
});
