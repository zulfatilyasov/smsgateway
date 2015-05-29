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

    aggregateGroups:()->
        AppDispatcher.handleViewAction
            actionType: ContactConstants.AGGREGATE_GROUPS

    triggerChange:()->
        AppDispatcher.handleViewAction
            actionType: ContactConstants.TRIGGER_CHANGE

    getUserVariables:(userId) ->
      apiClient.getUserVariables(userId)
        .then (resp) ->
          variables = resp.body
          AppDispatcher.handleViewAction
              actionType: ContactConstants.GET_VARIABLES_SUCCESS
              variables: variables

        , (err) ->
          AppDispatcher.handleViewAction
              actionType: ContactConstants.GET_VARIABLES_FAIL
              error: err

    createContactVariable:(variable) ->
      apiClient.createContactVariable(variable)
        .then (resp)->
          savedVariable = resp.body
          debugger
          AppDispatcher.handleViewAction
              actionType: ContactConstants.CREATE_VARIABLE_SUCCESS
              variable: savedVariable
        , (err) ->
          AppDispatcher.handleViewAction
              actionType: ContactConstants.CREATE_VARIABLE_FAIL
              error: err

    replaceGroups:(targetGroups, sourceGroups) ->
      _.map targetGroups, (group) ->
        if group.id is null
          matchingGroup =_.first _.filter(sourceGroups, name:group.name)
          group.id = matchingGroup.id
        id:group.id
        name:group.name

    selectSingle: (id) ->
      AppDispatcher.handleViewAction
        actionType: ContactConstants.SELECT_CONTACT
        id: id

    selectAllItems: (value) ->
      AppDispatcher.handleViewAction
          actionType: ContactConstants.SELECT_ALL_CONTACTS
          value: value

    deleteContacts: (contactIds)->
      apiClient.deleteContacts contactIds
        .then (resp) ->
                AppDispatcher.handleViewAction
                    actionType: ContactConstants.DELETED_CONTACTS
                    contactIds: contactIds
            , (err) ->
                AppDispatcher.handleViewAction
                    actionType: ContactConstants.DELETE_CONTACTS_FAIL
                    contactIds: contactIds

    clearEdit:() ->
      AppDispatcher.handleViewAction
          actionType: ContactConstants.CLEAR_EDITED_CONTACT

    editContact: (contact) ->
      AppDispatcher.handleViewAction
          actionType: ContactConstants.EDIT_CONTACT
          contact: contact

    createMultipleGroups: (userId, groups, cb)->
      apiClient.createUserGroups userId, groups
        .then (resp) ->
          createdGroups = resp.body
          AppDispatcher.handleViewAction
            actionType: GroupConstants.SAVE_GROUP_SUCCESS
            groups: createdGroups
          cb createdGroups

    createMultipleContacts: (contacts, groups, userId) ->
      contacts = _.map contacts,  (c) ->
        c.groups = groups
        return c

      apiClient.saveContact(userId, contacts)
        .then (resp) ->
          savedContacts = resp.body
          AppDispatcher.handleViewAction
            actionType: ContactConstants.CREATE_MULTIPLE_SUCCESS
            contacts: savedContacts
        , (err) ->
          AppDispatcher.handleViewAction
            actionType: ContactConstants.CREATE_MULTIPLE_FAIL
            error: err

    importContacts: (contacts, groups, userId) ->
      newGroups = _.filter groups, id:null
      if newGroups.length
        @createMultipleGroups userId, newGroups, (createdGroups) ->
          groups = ContactActions.replaceGroups groups, createdGroups
          ContactActions.createMultipleContacts(contacts, groups, userId)
      else
          ContactActions.createMultipleContacts(contacts, groups, userId)

      AppDispatcher.handleViewAction
        actionType: ContactConstants.IMPORT_CONTACTS

    resetImportMessages:->
      AppDispatcher.handleViewAction
        actionType: ContactConstants.RESET_IMPORT_MESSAGES

    saveContact: (contact) ->
      newGroups = _.filter contact.groups, id:null
      if newGroups.length
        @createMultipleGroups contact.userId, newGroups, (createdGroups) ->
          contact.groups = ContactActions.replaceGroups contact.groups, createdGroups
          ContactActions.createContact contact
      else
        contact.groups = ContactActions.replaceGroups contact.groups
        ContactActions.createContact contact

      AppDispatcher.handleViewAction
        actionType: ContactConstants.SAVE
        contact: contact

    createContact: (contact) ->
      apiClient.saveContact(contact.userId, contact)
        .then (resp) ->
          savedContact = resp.body
          savedContact.new = if contact.id then false else true
          AppDispatcher.handleViewAction
            actionType: ContactConstants.SAVE_SUCCESS
            contact: savedContact
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

    updateContactGroups: (contacts, selectedGroups, aggregatedGroups) ->
      _.forEach selectedGroups, (group) ->
        _.forEach contacts, (contact) ->
          if not _.any(contact.groups, id:group.id)
            contact.groups.push
              name:group.name
              id:group.id
      _.forEach aggregatedGroups, (group) ->
        if not _.any(selectedGroups, id:group.id)
          for contact in contacts
            _.remove(contact.groups, id:group.id)
      @submitContacts contacts

    submitGroups:(groups) ->
      apiClient.updateMultipleGroups groups
        .then (resp) ->
          AppDispatcher.handleViewAction
            actionType: GroupConstants.UPDATED_GROUPS
            groups: groups
        , (err) ->
          console.log err


    submitContacts: (contacts) ->
      contacts = _.map contacts, (c) -> _.omit c, ['checked', 'key', 'new']
      apiClient.updateMultipleContacts contacts
        .then (resp) ->
          AppDispatcher.handleViewAction
            actionType: ContactConstants.UPDATED_CONTACTS
            contacts: contacts
        , (err) ->
          console.log err

    checkNewGroupsAndUpdateContacts:(userId, contacts, selectedGroups, newGroups, aggregatedGroups) ->
      if newGroups.length
        @createMultipleGroups userId, newGroups, (createdGroups) =>
          selectedGroups = selectedGroups.concat createdGroups
          @updateContactGroups contacts, selectedGroups, aggregatedGroups
      else
        @updateContactGroups contacts, selectedGroups, aggregatedGroups

    getUserContacts: (userId, groupId, skip=0, limit=50) ->
        if @contactsLoaded
            console.log 'contacts already loaded'
            return

        apiClient.getUserContacts userId, groupId, skip, limit
            .then (resp) ->
                    contacts = resp.body.contacts or resp.body
                    AppDispatcher.handleViewAction
                        actionType: ContactConstants.RECEIVED_ALL_CONTACTS
                        contacts: contacts
                        skiped:skip
                        isGroupContacts: if groupId then true else false
                    @contactsLoaded = true
                , (err) ->
                    AppDispatcher.handleViewAction
                        actionType: ContactConstants.GET_ALL_CONTACTS_FAIL
                        error: err

        AppDispatcher.handleViewAction
            actionType: ContactConstants.GET_CONTACTS

module.exports = ContactActions