React = require('react')
loadScript = require 'load-script'
contactActions = require '../../actions/ContactActions.coffee'
contactStore = require '../../stores/ContactStore.coffee'

loadHandsOntableCss= ->
    cssId = 'handontableCss'
    if !document.getElementById(cssId)
        head  = document.getElementsByTagName('head')[0]
        link  = document.createElement('link')
        link.id   = cssId
        link.rel  = 'stylesheet'
        link.type = 'text/css'
        link.href = 'https://cdnjs.cloudflare.com/ajax/libs/handsontable/0.14.1/handsontable.full.min.css'
        link.media = 'all'
        head.appendChild(link)

window.sources = ['name', 'phone', 'email']

ImportContacts = React.createClass
  getInitialState: ->
    fields:contactStore.variableNames()

  componentWillUnmount: ->
    contactStore.removeChangeListener @onChange

  onChange:->
    @setState
      fields:contactStore.variableNames()


  componentDidMount: ->
    contactStore.addChangeListener @onChange
    contactActions.triggerChange()
    loadHandsOntableCss()
    self = @
    loadScript 'https://cdnjs.cloudflare.com/ajax/libs/handsontable/0.14.1/handsontable.full.min.js', ->
      data = [
        ["name", "phone"],
        ["Zulfat", '+7123456789'],
        ["Example", '+1998877665'],
      ]
      container = document.getElementById('handsontable')
      window.hot = new Handsontable container,
        data: data
        colWidths:'100%'
        minSpareRows: 1
        contextMenu: true
        rowHeaders: true
        cells: (row, col, prop) ->
          cellProperties = {}
          if row is 0
            cellProperties.type= 'dropdown'
            cellProperties.source = self.state.fields
          cellProperties

  render: ->
    <div id="handsontable"></div>

module.exports = ImportContacts