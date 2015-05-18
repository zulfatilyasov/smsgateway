BaseStore = require './BaseStore.coffee'
contactConstants = require '../constants/ContactConstants.coffee'
groupConstants = require '../constants/GroupConstants.coffee'

_inProgress = false
_saving = false
_contactsList = []
_defaultGroupRouteList = [{
    route: 'allContacts', 
    text: 'All Contacts'
}]
_groupRouteList = _defaultGroupRouteList
_groupOptions = []
_loadingGroups = false

class ContactStore extends BaseStore
    constructor: (actions) ->
        super(actions)

    ContactList: ->
        _contactsList

    InProgress: ->
        _inProgress

    isSaving: ->
        _saving

    loadingGroups: ->
        _loadingGroups

    groupRouteList: ->
        _groupRouteList

    groupOptions: ->
        _groupOptions

actions = {}

actions[contactConstants.GET_CONTACTS] = (action) ->
    _inProgress = true
    _contactsList = []
    storeInstance.emitChange()

actions[contactConstants.SAVE] = (action) ->
    _saving = true
    storeInstance.emitChange()

actions[contactConstants.SAVE_SUCCESS] = (action) ->
    _saving = false
    action.contact.new = true
    _contactsList.push action.contact
    storeInstance.emitChange()

actions[contactConstants.SAVE_FAIL] = (action) ->
    _saving = false
    _error = action.error
    storeInstance.emitChange()

actions[contactConstants.RECEIVED_ALL_CONTACTS] = (action) ->
    _contactsList = action.contacts;
    console.log _contactsList
    _inProgress = false;
    storeInstance.emitChange();

actions[groupConstants.GET_GROUPS] = (action) ->
    _loadingGroups = true
    storeInstance.emitChange()

actions[groupConstants.GROUP_DELETED] = (action) ->
    _.remove _groupRouteList, data:action.groupId
    _.remove _groupOptions, value:action.groupId
    storeInstance.emitChange()

actions[groupConstants.SAVE_GROUP_SUCCESS] = (action) ->
    routeList = _.map action.groups, (group) ->
        route: 'groupContacts'
        data: group.id
        iconClassName: 'icon icon-close'
        text: group.name
        params:
            groupId: group.id

    options = _.map action.groups, (group) ->
        value:group.id
        label:group.name 

    _groupOptions = _groupOptions.concat(options)
    _groupRouteList = _groupRouteList.concat(routeList)
    storeInstance.emitChange()

actions[groupConstants.RECEIVED_ALL_GROUPS] = (action) ->
    routeList = _.map action.groups, (group) ->
        route: 'groupContacts'
        data: group.id
        iconClassName: 'icon icon-close'
        text: group.name
        params:
            groupId: group.id
    _groupRouteList = _defaultGroupRouteList.concat(routeList)

    _groupOptions = _.map action.groups, (group) ->
        value:group.id
        label:group.name 

    _loadingGroups = false;
    storeInstance.emitChange();

storeInstance = new ContactStore(actions)

module.exports = storeInstance
