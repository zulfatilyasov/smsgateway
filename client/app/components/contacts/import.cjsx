React = require('react')
contactActions = require '../../actions/ContactActions.coffee'
contactStore = require '../../stores/ContactStore.coffee'
scripts = require '../../services/scripts.coffee'
uiEvents = require '../../uiEvents.coffee'
Select = require 'react-select'

ImportContacts = React.createClass
  getInitialState: ->
    fields:contactStore.variableNames()
    importing:contactStore.importing()
    importSuccess:contactStore.imported()
    importError:contactStore.importError()
    addressList:contactStore.groupOptions()

  componentWillUnmount: ->
    contactStore.removeChangeListener @onChange
    contactActions.resetImportMessages()

  onChange:->
    fields = contactStore.variableNames()
    fields.push 'Create New'
    @setState
      fields:fields
      addressList:contactStore.groupOptions()
      importing:contactStore.importing()
      importSuccess:contactStore.imported()
      importError:contactStore.importError()

  addressChanged: (e, values)->
    window.groups = values

  componentWillUnmount: ->
    if hot
      hot.destroy() 

  componentDidMount: ->
    self = @
    contactStore.addChangeListener @onChange
    contactActions.triggerChange()
    scripts.loadCss('handsontableCss', scripts.handsOnTableCss)
    scripts.loadJs scripts.handsOnTableJs, ->
      data = [
        ["Name", "Phone"],
        ["Zulfat", '+7123456789'],
        ["Example", '+1998877665'],
      ]
      container = document.getElementById('handsontable')
      window.hot = new Handsontable container,
        data: data
        colWidths:'100%'
        height:->
          pageHeaderHeight = 165
          viewportHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0)
          return viewportHeight - pageHeaderHeight - 60

        minSpareRows: 1
        fixedRowsTop:1
        contextMenu: true
        rowHeaders: true
        beforeChange: (changes, source)->
          if changes[0][3] is 'Create New'
            position =
              row:changes[0][0]
              col:changes[0][1]
            setTimeout ->
              uiEvents.showAddFieldDialog(position)
            , 100
            return false
        cells: (row, col, prop) ->
          cellProperties = {}
          if row is 0
            cellProperties.type= 'dropdown'
            cellProperties.source = self.state.fields
            cellProperties.renderer = (instance, TD, row, col, prop, value, cellProperties)->
              if not _.includes self.state.fields, value
                TD.style.backgroundColor = 'red';
                TD.style.color = 'white';
              Handsontable.renderers.AutocompleteRenderer.apply(this, arguments);
          cellProperties

  render: ->
    infoMessage="You can copy/paste contacts from Excel or Google Spreadsheets. Or upload a csv file."
    if @state.importing
      infoMessage="Saving contacts..."

    if @state.importSuccess and not @state.importing
      infoMessage="Contacts saved successfully!"

    if @state.importError
      infoMessage="Error occured while saving contacts"

    <div className="import">
      <Select
        multi={true}
        options={@state.addressList}
        allowCreate={true}
        placeholder="Groups"
        className="input groupsInput"
        onChange={@addressChanged} />
      <div className="info">{infoMessage}</div>
      <div id="handsontable"></div>
    </div>

module.exports = ImportContacts