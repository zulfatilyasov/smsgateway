AppDispatcher = require '../AppDispatcher.coffee'
ContactConstants = require '../constants/ContactConstants.coffee'
GroupConstants = require '../constants/GroupConstants.coffee'
apiClient = require '../services/apiclient.coffee'

ContactActions = 
    contactsLoaded : false
    clean: ->
        @contactsLoaded = false
        AppDispatcher.handleViewAction
            actionType: ContactConstants.CLEAN

    createGroup:(name) ->
        apiClient.getUserGroups userId
            .then (resp) ->
                    groups = resp.body
                    AppDispatcher.handleViewAction
                        actionType: GroupConstants.RECEIVED_ALL_GROUPS
                        groups: groups
                , (err) ->
                    AppDispatcher.handleViewAction
                        actionType: GroupConstants.GET_ALL_GROUPS_FAIL
                        error: err

        AppDispatcher.handleViewAction
            actionType: GroupConstants.GET_GROUPS

    replaceGroups:(targetGroups, sourceGroups) ->
      _.map targetGroups, (group) ->
        if group.id is null
          matchingGroup =_.first _.filter(sourceGroups, name:group.name)
          group.id = matchingGroup.id
        id:group.id
        name:group.name

    saveContact: (contact) ->
      newGroups = _.filter contact.groups, id:null
      if newGroups.length
        apiClient.createUserGroups contact.userId, newGroups
          .then (resp) ->
            createdGroups = resp.body
            contact.groups = ContactActions.replaceGroups contact.groups, createdGroups
            ContactActions.createContact contact
            AppDispatcher.handleViewAction
              actionType: GroupConstants.SAVE_GROUP_SUCCESS
              groups: createdGroups
      else
            contact.groups = ContactActions.replaceGroups contact.groups
            ContactActions.createContact contact

      AppDispatcher.handleViewAction
        actionType: ContactConstants.SAVE
        contact: contact

    createContact: (contact) ->
      apiClient.createContact(contact.userId, contact)
        .then (resp) ->
          newContact = resp.body
          AppDispatcher.handleViewAction
            actionType: ContactConstants.SAVE_SUCCESS
            contact: newContact
        , (err) ->
          AppDispatcher.handleViewAction
            actionType: ContactConstants.SAVE_FAIL
            error: err

    getUserGroups: (userId) ->
        apiClient.getUserGroups userId
            .then (resp) ->
                    groups = resp.body
                    AppDispatcher.handleViewAction
                        actionType: GroupConstants.RECEIVED_ALL_GROUPS
                        groups: groups
                , (err) ->
                    AppDispatcher.handleViewAction
                        actionType: GroupConstants.GET_ALL_GROUPS_FAIL
                        error: err

        AppDispatcher.handleViewAction
            actionType: GroupConstants.GET_GROUPS

    deleteGroup: (userId, groupId) ->
      apiClient.deleteGroup userId, groupId
        .then (resp) ->
                AppDispatcher.handleViewAction
                    actionType: GroupConstants.GROUP_DELETED
                    groupId: groupId
            , (err) ->
                AppDispatcher.handleViewAction
                    actionType: GroupConstants.GROUP_DELETE_FAILED
                    error: err

    getUserContacts: (userId, groupId) ->
        if @contactsLoaded
            console.log 'contacts already loaded'
            return

        apiClient.getUserContacts userId, groupId
            .then (resp) ->
                    contacts = resp.body.contacts or resp.body
                    AppDispatcher.handleViewAction
                        actionType: ContactConstants.RECEIVED_ALL_CONTACTS
                        contacts: contacts
                    @contactsLoaded = true
                , (err) ->
                    AppDispatcher.handleViewAction
                        actionType: ContactConstants.GET_ALL_CONTACTS_FAIL
                        error: err

        AppDispatcher.handleViewAction
            actionType: ContactConstants.GET_CONTACTS

module.exports = ContactActions