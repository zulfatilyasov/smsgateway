AppDispatcher = require '../AppDispatcher.coffee'
UserContstants = require '../constants/UserConstants.js'
apiClient  = require '../services/apiclient.coffee'

loginDelay = 1000;
UserActions = 
    register: (registrationData) ->
        apiClient.register registrationData
            .then (resp) ->

                data = resp.body
                setTimeout  ->
                    AppDispatcher.handleServerAction
                        actionType: UserContstants.REGISTER_SUCCESS
                        data: data
                , loginDelay

            , err ->
                error = err.response.body.error
                setTimeout ->
                    AppDispatcher.handleServerAction
                        actionType: UserContstants.REGISTER_FAIL
                        error: error
                , loginDelay


        AppDispatcher.handleViewAction
            actionType: UserContstants.REGISTER
            registrationData: registrationData

    login: (creds) ->
        apiClient.login(creds.email, creds.password)
            .then (resp) ->
                data = resp.body

                setTimeout ->
                    AppDispatcher.handleServerAction
                        actionType: UserContstants.LOG_IN_SUCCESS
                        data: data
                , loginDelay

            , (err) ->
                error = err.response.body.error;
                setTimeout -> 
                    AppDispatcher.handleServerAction
                        actionType: UserContstants.LOG_IN_FAIL
                        error: error
                , loginDelay

        AppDispatcher.handleViewAction
            actionType: UserContstants.LOG_IN
            creds: creds

    logout: -> 
        AppDispatcher.handleViewAction
            actionType: UserContstants.LOG_OUT

module.exports = UserActions;
