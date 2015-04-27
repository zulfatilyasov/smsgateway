
describe('Message Actions', function() {
    var injector = require('inject?-../constants/MessageConstants.js!./MessageActions.coffee');
    var MessageContstants = require('../constants/MessageConstants.js');
    var dispatcher = jasmine.createSpyObj('dispatcher', ['handleViewAction']);
    var apiClient = jasmine.createSpyObj('apiClient', ['getUserMessages']);
    var userId = '123';
    var messages = ['hello'];

    apiClient.getUserMessages.and.callFake(function(userId) {
        return {
            then: function(cbSuccess) {
                cbSuccess({
                    body: messages
                })
            }
        }
    });

    var messageActions = injector({
        '../services/apiclient.coffee': apiClient,
        '../AppDispatcher.coffee': dispatcher
    });

    it('should be able to get user messages', function() {
        expect(messageActions.getUserMessages).toBeDefined();
    });

    it('should get messages through api', function() {
        messageActions.getUserMessages(userId);
        expect(apiClient.getUserMessages).toHaveBeenCalledWith(userId);
        expect(dispatcher.handleViewAction).toHaveBeenCalledWith({
            actionType: MessageContstants.RECEIVED_ALL_MESSAGES,
            messages: messages
        });
    });
});
