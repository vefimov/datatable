###
 * This work is licensed under the Creative Commons Attribution-NoDerivs 3.0 Unported License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nd/3.0/ or send a
 * letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
###

# define application namespace
window.Ex ?= {}

###
 * Provides and manages Ex.AttributeProvider instances
###
class Ex.AttributeProvider
  __init: ->
    @cfg = {}
    # Use jQuery’s event system instead of building your own
    @__eventEmitter = jQuery(@)

  ###
   * Execute all handlers and behaviors attached to the matched elements for the given event type.
  ###
  emit: (evt, data) ->
    @__eventEmitter.trigger evt, data

  ###
   * Attach a handler to an event for the elements. The handler is executed at most once per element.
  ###
  once: (evt, handler) ->
    @__eventEmitter.one evt, handler

  ###
   * Attach an event handler function for one or more events to the selected elements.
  ###
  on: (evt, handler) ->
    @__eventEmitter.bind evt, handler

  ###
   * Remove an event handler.
  ###
  off: (evt, handler) ->
    @__eventEmitter.unbind evt, handler

  ###
   * Sets the value of a config.
  ###
  set: (name, value) ->
    @emit("#{name}Change", value);
    @cfg[name] = value

  ###
   * Returns the current value of the attribute.
  ###
  get: (name) ->
    return @cfg[name]

###
 * DataTable class
 * The constructor accepts the following parameters:
 *  - container {HTMLElement} Container element for the TABLE.
 *  - configs {Object} (optional) Object literal of configuration values.
###
class Ex.DataTable
  $.extend @prototype, Ex.AttributeProvider.prototype

  constructor: (container, configs) ->
    @__init()
    defaults =
      columns: [] # Array of object literal Column definitions.
      store: null # DataSource instance
      fields: null # list of the fields
      sortedBy:
        key: null,
        dir: "ASC"

    @container = jQuery container
    @cfg = $.extend(defaults, configs)

    @theadEl = jQuery "<thead />"
    @tbodyEl = jQuery "<tbody />"
    @container.empty().append(@theadEl).append(@tbodyEl)
    @renderColumns()
    @render()

  getStore: ->
    @get("store")

  renderColumns: ->
    theadRowEl = jQuery "<tr />"
    columns = @get("columns")

    for column in columns
      thEl = jQuery "<th />"
      thEl.append jQuery("<div />").text(column.label)
      thEl.on "click", @onEventSortColumn.bind null, column
      
      if column.hidden
        thEl.addClass("hidden").css("display", "none")
      
      theadRowEl.append thEl

    @theadEl.append theadRowEl

  ###
   * Renders the view with existing records
  ###
  render: ->
    store = @getStore()
    storeData = store.getData()
    columns = @get("columns")
    sortedBy = @get("sortedBy")
    rowFormatter = @get("rowFormatter")
    
    # sort the data
    storeData.sort (a, b) ->
      asc = sortedBy.dir is "ASC"
      val1 = a[sortedBy.key]
      val2 = b[sortedBy.key]
      if val1 < val2
        return if asc then -1 else 1
      if val1 is val2
        return 0
      else
        return if asc then 1 else -1
    
    @tbodyEl.empty()
    for record in storeData
      trEl = jQuery "<tr />"
      rowFormatter?(trEl, record)
      
      for column in columns
        tdEl = jQuery "<td />"
        
        # call cell formatter
        if typeof column.formatter is "function"
          column.formatter tdEl, column, record
        else
          tdEl.append jQuery("<div />").text(record[column.key])
        
        if column.hidden
          tdEl.addClass("hidden").css("display", "none")
        
        trEl.append tdEl
      @tbodyEl.append trEl

  ###
   * Custom event handler to sort Column.
  ###
  onEventSortColumn: (column, event) =>
    if column.sortable
      dir = if @get("sortedBy").dir is "ASC" then "DESC" else "ASC"
      # Update UI via sortedBy
      @sortColumn column, dir
  
  ###
   * Sorts given Column. 
  ###
  sortColumn: (column, dir) ->
    @set("sortedBy", key: column.key, dir: dir)
    @render()


###
 * The Store class encapsulates a client side cache of Model objects
###
class Ex.Store
  $.extend @prototype, Ex.AttributeProvider.prototype
  
  _data: []
  
  constructor: (configs) ->
    @__init()
    @setData configs.data
    @cfg = {}
  
  setData: (data) ->
    @_data = jQuery.extend [], data
  
  getData: ->
    @_data

###
 * Small helper class to make creating stores from Array data easier
###
class Ex.ArrayStore extends Ex.Store
  constructor: (configs) ->
    super


