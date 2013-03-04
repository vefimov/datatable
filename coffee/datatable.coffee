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
      paginator: null
      columns: [] # Array of object literal Column definitions.
      store: null # DataSource instance
      #fields: null # list of the fields
      sortedBy:
        key: null,
        dir: "ASC"

    @container = jQuery container
    @cfg = $.extend(defaults, configs)

    @theadEl = jQuery "<thead />"
    @tbodyEl = jQuery "<tbody />"
    @container.empty().append(@theadEl).append(@tbodyEl)
    @renderColumns()
    
    sortedBy = @get("sortedBy")
    if sortedBy.key
      @sortColumn(@getColumn("key", sortedBy.key), sortedBy.dir)
    else
      @render()
  
  ###
   * Find column by attribute name and its value
  ###
  getColumn: (attrName, attrValue) ->
    columns = @get("columns")
    for column in columns
      return column if column[attrName] is attrValue
    return null
  
  ###
   * Get store instance
  ###
  getStore: ->
    @get("store")

  ###
   * Render the TH elements
  ###
  renderColumns: ->
    theadRowEl = jQuery "<tr />"
    columns = @get("columns")

    for column in columns
      thEl = jQuery "<th />"
      
      # add css classes to th element
      thEl.addClass("ex-dt-sortable") if column.sortable
      thEl.addClass("ex-dt-hidden").css("display", "none") if column.hidden
      thEl.addClass("ex-dt-col-#{column.key}")
      
      thEl.append jQuery("<div />").text(column.label)
      thEl.on "click", @onEventSortColumn.bind null, column
        
      column.thEl = thEl
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
      #yui-dt-even
      rowFormatter?(trEl, record)
      trEl.addClass "ex-dt-#{if _i % 2 then 'odd' else 'even'}"
      
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
    console.time "Sorting"
    if column.sortable
      dir = if @get("sortedBy").dir is "ASC" then "DESC" else "ASC"
      # Update UI via sortedBy
      @sortColumn column, dir
    console.timeEnd "Sorting"
  
  ###
   * Sorts given Column. 
  ###
  sortColumn: (column, dir) ->
    @set("sortedBy", key: column.key, dir: dir)
    column.thEl.parent().find(".ex-dt-asc, .ex-dt-desc").removeClass("ex-dt-asc ex-dt-desc")
    column.thEl.addClass "ex-dt-#{dir.toLowerCase()}"
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

###
 * Paginator 
 * Parameters:
 *    config <Object> Object literal to set instance and ui component configuration.
###
class Ex.Paginator
  $.extend @prototype, Ex.AttributeProvider.prototype
  
  _currentPage: 1
  
  constructor: (config) ->
    @__init()
    defaults =
      rowsPerPage: 30
      containers: ''
      totalRecords: 0
    
    config = $.extend(defaults, config)
    config.containers = $(config.containers)
    @cfg = config
    
    config.containers.on("click", "li", @_handleStateChange)
    @_initUIComponents()
    @_selfSubscribe()
    @render()
    
  updateVisibility: ->
    
  ###
   * Render the pagination controls per the format attribute into the specified container nodes.
  ###
  render: =>
    totalRecords = +@get("totalRecords")
    rowsPerPage = +@get("rowsPerPage")
    containers = @get("containers")
    
    containers.find(".ex-pg-page").remove()
    nextEl = containers.find(".ex-pg-next")
    
    totalPages = totalRecords / rowsPerPage
    totalPages++ if totalPages > Math.floor(totalPages)
    
    i = @getCurrentPage()
    while i <= totalPages
      liEl = jQuery("<li />", class: "ex-pg-page").append(
        jQuery("<a />", href: "#", text: i)
      )
      liEl.insertBefore(nextEl)
      
      i++
       
  getCurrentPage: ->
    return @_currentPage
    
  ###
   * Set the current page to the provided page number if possible.
   * Parameters:
   *  newPage <number> the new page number
  ###
  setPage: (newPage)->
    @_currentPage = newPage 
    
  ###
   *  Fires the pageChange event when the state attributes have changed
  ###
  _handleStateChange: (event)->
    
    
  ###
   * Subscribes to instance attribute change events to automate certain behaviors.
  ###
  _selfSubscribe: ->
    @on "totalRecordsChange", @render
  
    
  _initUIComponents: ->
    ulEl = jQuery("<ul />", class: "ex-pg")
    ulEl.append(
      jQuery("<li />", class: "ex-pg-first").append(jQuery("<a />", href: "#", text: "First"))
      jQuery("<li />", class: "ex-pg-prev").append(jQuery("<a />", href: "#", text: "Prev"))
      jQuery("<li />", class: "ex-pg-next").append(jQuery("<a />", href: "#", text: "Next"))
      jQuery("<li />", class: "ex-pg-last").append(jQuery("<a />", href: "#", text: "Last"))
    )
    
    @get("containers").empty().append(ulEl)
    
  