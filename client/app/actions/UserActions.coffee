AppDispatcher = require '../AppDispatcher.coffee'
UserContstants = require '../constants/UserConstants.js'
apiClient  = require '../services/apiclient.coffee'
messageActions = require './MessageActions.coffee'
router = require '../router.coffee'
socketIO = require '../services/socket.coffee'
ioConstants = require '../../../common/constants/ioConstants.coffee'

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

            , (err) ->
                error = err.response.body.error
                setTimeout ->
                    AppDispatcher.handleServerAction
                        actionType: UserContstants.REGISTER_FAIL
                        error: error
                , loginDelay


        AppDispatcher.handleViewAction
            actionType: UserContstants.REGISTER
            registrationData: registrationData

    startWatchingDevice:() ->
        socket = socketIO.getSocket()
        socket.on ioConstants.PHONE_MODEL, (deviceModel) ->
            AppDispatcher.handleServerAction
                actionType:UserContstants.DEVICE_CONNECTED
                deviceModel:deviceModel
                
        socket.on ioConstants.PHONE_DISCONNECTED, (deviceModel) ->
            AppDispatcher.handleServerAction
                actionType:UserContstants.DEVICE_DISCONNECTED
                deviceModel:deviceModel

    stopWatchingDevice:() ->
        socketIO.getSocket().removeAllListeners ioConstants.PHONE_MODEL

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
        @stopWatchingDevice()
        router.transitionTo('/login');
        AppDispatcher.handleViewAction
            actionType: UserContstants.LOG_OUT

    requestResetPassword: (email) ->
        apiClient.requestResetPassword(email)
            .then (resp) ->
                data = resp.body
                setTimeout ->
                    AppDispatcher.handleServerAction
                        actionType: UserContstants.RESET_PASSWORD_SUCCESS
                        data: data
                , loginDelay

            , (err) ->
                error = err.response.body.error;
                setTimeout -> 
                    AppDispatcher.handleServerAction
                        actionType: UserContstants.RESET_PASSWORD_FAIL
                        error: error
                , loginDelay

        AppDispatcher.handleViewAction
            actionType: UserContstants.RESET_PASSWORD
            email: email

    getUserDevice: ->
        apiClient.getUserDevice()
            .then (resp) ->
                    deviceModel = resp.body.model
                    if deviceModel
                        AppDispatcher.handleServerAction
                            actionType: UserContstants.DEVICE_CONNECTED
                            deviceModel: deviceModel
                , (err) ->
                    console.log err


    resetPassword: (accessToken, password, confirmation) ->
        apiClient.resetPassword accessToken, password, confirmation
            .then (resp) ->
                data = resp.body
                setTimeout ->
                    AppDispatcher.handleServerAction
                        actionType: UserContstants.SET_PASSWORD_SUCCESS
                        data: data
                , loginDelay

            , (err) ->
                setTimeout -> 
                    AppDispatcher.handleServerAction
                        actionType: UserContstants.SET_PASSWORD_FAIL
                        error: err
                , loginDelay

        AppDispatcher.handleViewAction
            actionType: UserContstants.SET_PASSWORD


module.exports = UserActions;
