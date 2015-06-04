BaseStore = require './BaseStore.coffee'
contactConstants = require '../constants/ContactConstants.coffee'
groupConstants = require '../constants/GroupConstants.coffee'
_ = require 'lodash'

_inProgress = false
_hasMore = true
_curGroupId = null
_saving = false
_importing = false;
_imported = false;
_importError = null;
_pageId = 0;
_contactsList = []
_allContacts = []
_selectedContactGroups = []
_editedContact = null
_defaultGroupRouteList = [{
    route: 'allContacts', 
    text: 'All Contacts'
}]
_groups=[]
_groupRouteList = _defaultGroupRouteList
_groupOptions = []
_loadingGroups = false
_addressList = []
_variables = []

isPhone = (value) ->
    digits = value.match(/\d/g).length
    value.length < 15 and digits > 6 and digits < 12 and not isEmail(value)

isEmail = (value) ->
    re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
    re.test(value)

class ContactStore extends BaseStore
    constructor: (actions) ->
        super(actions)

    ContactList: ->
        _contactsList

    imported: ->
        _imported

    importing:->
        _importing

    pageId:->
        _pageId

    hasMore:->
        _hasMore

    importError:->
        _importError

    variableNames:()->
        names = _.map _variables, (v) ->
            v.name

        ['Name','Phone', 'Email'].concat names

    origVariables:->
        _variables
        
    variables: ->
        _.map _variables, (v) ->
            text:v.name
            payload:v

    InProgress: ->
        _inProgress

    isSaving: ->
        _saving

    loadingGroups: ->
        _loadingGroups

    groupRouteList: ->
        _groupRouteList

    editedContact: ->
        _editedContact

    getSelectedConactOptions:->
        _(_contactsList)
            .filter({'checked': true})
            .map (c) ->
                id:c.id
                isContact:true,
                label:c.name
                value:c.phone
            .value()

    selectedContactIds: ->
        _.pluck(_.filter(_contactsList, {'checked': true}), 'id')

    selectedContacts: ->
        _.filter _contactsList, {'checked': true}

    selectedContactGroups: ->
        _selectedContactGroups

    mapGroups: (groups) ->
        _.map groups, (g) ->
            name: g.label
            id: if g.value is g.label then null else g.value

    getOriginalGroups:(groupsToMap) ->
        _.filter _groups, (_g) ->
            _.any groupsToMap, 'value':_g.id

    groupOptions: ->
        _groupOptions

    addressList: ->
        _addressList

    stripContacts:(addressList, userId) ->
        newContacts= _(addressList)
            .filter (c) ->
                c.value is c.label and not c.isContact and (isPhone(c.value) or isEmail(c.value))
            .map (c) ->
                name: c.label
                userId:userId
                phone:if isPhone(c.value) then c.value else null
                email:if isEmail(c.value) then c.value else null
                id:null
            .value()

        contacts = _.filter addressList, (c) -> c.isContact or isPhone(c.value) or isEmail(c.value)
        contacts = _.map contacts, (c) ->
            name: c.label
            phone:if isPhone(c.value) then c.value else null
            email:if isEmail(c.value) then c.value else null
            id:c.id

        groups =
            _(addressList)
                .filter isGroup: true
                .map (g) ->
                    id:g.value
                    name:g.name
                .value()

        contacts: contacts.concat(newContacts)
        groups: groups
actions = {}

actions[contactConstants.GET_CONTACTS] = (action) ->
    _inProgress = true
    storeInstance.emitChange()

actions[contactConstants.CLEAR_EDITED_CONTACT] = (action) ->
    _editedContact = null
    storeInstance.emitChange()

actions[contactConstants.EDIT_CONTACT] = (action) ->
    _editedContact = action.contact
    _editedContact.groups = _.map _editedContact.groups, (group) ->
        value:group.id
        label:group.name 
    storeInstance.emitChange()

actions[contactConstants.SAVE] = (action) ->
    _saving = true
    storeInstance.emitChange()

actions[contactConstants.IMPORT_CONTACTS] = (action) ->
    _importing = true
    _imported = false
    _importError = null
    storeInstance.emitChange()

actions[contactConstants.GET_ADDRESSLIST_SUCCESS] = (action) ->
    _addressList = action.addresses
    storeInstance.emitChange()

actions[contactConstants.CREATE_MULTIPLE_SUCCESS] = (action) ->
    _importing = false
    _imported = true
    _importError = null
    storeInstance.emitChange()

actions[contactConstants.RESET_IMPORT_MESSAGES] = ->
    _importing = false
    _imported = false
    _importError = null
    storeInstance.emitChange()

actions[contactConstants.CREATE_MULTIPLE_FAIL] = (action) ->
    _importing = false
    _imported = false
    _importError = action.error;
    storeInstance.emitChange()

actions[contactConstants.SELECT_ALL_CONTACTS] = (action) ->
    for contact in _contactsList
        contact.checked = action.value
    storeInstance.emitChange()

actions[contactConstants.TRIGGER_CHANGE] = (action) ->
    storeInstance.emitChange()

actions[contactConstants.UPDATED_CONTACTS] = (action) ->
    _contactsList = _.map _contactsList, (contact) ->
        for updatedContact in action.contacts
            return updatedContact if updatedContact.id is contact.id
        return contact
    storeInstance.emitChange()

actions[contactConstants.AGGREGATE_GROUPS] = () ->
    selectedContacts = storeInstance.selectedContacts()
    _selectedContactGroups = _.filter _groupOptions, (group) ->
        _.every selectedContacts, (contact) ->
            _.any contact.groups, id:group.value
    storeInstance.emitChange()
        
actions[contactConstants.SELECT_CONTACT] = (action) ->
    contact.checked = !contact.checked for contact in _contactsList when contact.id is action.id

actions[contactConstants.SAVE_SUCCESS] = (action) ->
    _saving = false
    if action.contact.new
        _contactsList.unshift action.contact
    else
        _contactsList = _.map _contactsList, (c) ->
            if c.id is action.contact.id then action.contact else c
        _editedContact = null

    storeInstance.emitChange()

actions[contactConstants.CREATE_VARIABLE_SUCCESS] = (action) ->
    _variables.push action.variable
    storeInstance.emitChange()

actions[contactConstants.SAVE_MULTIPLE_CONTACTS_SUCCESS] = (action) ->
    _saving = false
    if _.isArray(action.contacts)
        contacts = _.map action.contacts, (c) -> 
            c.new = true
            return c
        _allContacts = _allContacts.concat contacts
    else
        action.contacts.new = true
        _allContacts.push(action.contacts);
    storeInstance.emitChange()

actions[contactConstants.SAVE_FAIL] = (action) ->
    _saving = false
    _error = action.error
    storeInstance.emitChange()

actions[contactConstants.RECEIVED_ALL_CONTACTS] = (action) ->
    if action.groupId is _curGroupId and action.contacts.length < 50
        _hasMore = false
    else
        _hasMore = true

    if action.skiped is 0
        _pageId = 1

    if _curGroupId isnt action.groupId
        _curGroupId = action.groupId
    else
        _pageId++

    _contactsList = if action.skiped>0 then _contactsList.concat(action.contacts) else action.contacts
    if not action.isGroupContacts
        _allContacts = if action.skiped>0 then _allContacts.concat(action.contacts) else action.contacts
    _inProgress = false;
    storeInstance.emitChange();

actions[groupConstants.GET_GROUPS] = (action) ->
    _loadingGroups = true
    storeInstance.emitChange()

actions[contactConstants.GET_VARIABLES_SUCCESS] = (action) ->
    _variables = action.variables
    storeInstance.emitChange()

actions[groupConstants.GET_VARIABLES_FAIL] = (action) ->
    _getVarsError = action.error

actions[groupConstants.GROUP_DELETED] = (action) ->
    _.remove _groupRouteList, data:action.groupId
    _.remove _groupOptions, value:action.groupId
    _.remove _groups, id:action.groupId
    storeInstance.emitChange()

actions[contactConstants.DELETED_CONTACTS] = (action) ->
    deletedIds = action.contactIds
    _contactsList = _.reject _contactsList, (c) -> _.includes(deletedIds, c.id)
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
        isGroup:true
        label:group.name 

    _groupOptions = _groupOptions.concat(options)
    _groupRouteList = _groupRouteList.concat(routeList)
    _groups = _groups.concat(action.groups)
    storeInstance.emitChange()

actions[contactConstants.SEARCH_CONTACTS] = (action)->
    _contactsList = action.contacts
    storeInstance.emitChange()

actions[groupConstants.RECEIVED_ALL_GROUPS] = (action) ->
    _groups = action.groups
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
        isGroup:true
        label:group.name 

    _loadingGroups = false;
    storeInstance.emitChange();

storeInstance = new ContactStore(actions)

module.exports = storeInstance
