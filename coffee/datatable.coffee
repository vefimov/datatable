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
    #if @cfg[name] isnt value
    @cfg[name] = value 
    @emit "#{name}Change", value

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
    
    #_data: []
    
    constructor: (container, configs) ->
        @__init()
        defaults =
          paginator: null
          columns: [] # Array of object literal Column definitions.
          store: null # DataSource instance
          filters: []
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
        
        @initEvents()
    
    initEvents: ->
        if paginator = @get("paginator")
            paginator.on "currentPageChange", @render
            paginator.on "rowsPerPageChange", @render
            
        @getStore().on "onDataChange", (data) ->
            if paginator
                paginator.setTotalRecords data.length
            else
                @render()

        for filter in @get("filters")
            filter.on "valueChange", @render
                
    
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
      
    ###getData: ->
      @_data
      
    setData: (data) ->
      @_data = data###
    
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
    render: =>
        console.time("Rendering data")
        store = @getStore()
        storeData = store.getData()
        columns = @get("columns")
        sortedBy = @get("sortedBy")
        rowFormatter = @get("rowFormatter")
        paginator = @get("paginator")
        filters = @get("filters")
        
        #if filters.length
        for filter in filters
            if filter.isSelected()
                storeData = storeData.filter (element, index, array)->
                    filter.filter(element, index, array)
        
        paginator.setTotalRecords(storeData.length) if paginator
        
        from = 0
        to = storeData.length
        
        if paginator
            from = (paginator.getCurrentPage() - 1) * paginator.getRowsPerPage()
            to = paginator.getCurrentPage() * paginator.getRowsPerPage()
        
        storeData = storeData.slice from, to
        
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
            
            tdEl.on "click", (event) =>
                @onCellClick(event, column, record, @)
            
            trEl.append tdEl
          @tbodyEl.append trEl
          
        console.timeEnd("Rendering data")
          
    onCellClick: (event, column, record, dataTable)->
        console.log "onCellClickEvent", arguments
    
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
      column.thEl.parent().find(".ex-dt-asc, .ex-dt-desc").removeClass("ex-dt-asc ex-dt-desc")
      column.thEl.addClass "ex-dt-#{dir.toLowerCase()}"
      @getStore().sort column.key, dir
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
      @emit "onDataChange", @_data
    
    getData: ->
      @_data
      
    sortData: (key, dir) ->
      

###
 * Small helper class to make creating stores from Array data easier
###
class Ex.ArrayStore extends Ex.Store
    constructor: (configs) ->
      super
    
    sort: (key, dir) ->
        # sort the data
        @getData().sort (a, b) ->
          asc = dir is "ASC"
          val1 = a[key]
          val2 = b[key]
          if val1 < val2
            return if asc then -1 else 1
          if val1 is val2
            return 0
          else
            return if asc then 1 else -1

###
 * Paginator 
 * Parameters:
 *    config <Object> Object literal to set instance and ui component configuration.
###
class Ex.Paginator
    $.extend @prototype, Ex.AttributeProvider.prototype
    
    #_currentPage: 1
    
    constructor: (config) ->
      @__init()
      defaults =
        rowsPerPage: 30
        rowsPerPageSelect: null 
        containers: ''
        totalRecords: 0
        currentPage: 1
        alwaysVisible: false
      
      config = $.extend(defaults, config)
      config.containers = $(config.containers)
      #config.rowsPerPageSelect = $(config.containers)
      @cfg = config
      
      @_initUIComponents()
      @initEvents()
      @_selfSubscribe()
      #@updateState()
      @setPage 1
      
    updateVisibility: =>
      containers = @get("containers")
      prev = containers.find(".ex-pg-first, .ex-pg-prev")
      next = containers.find(".ex-pg-last, .ex-pg-next")
      
      if (prev.hasClass("disabled") && @hasPrevPage()) || !@hasPrevPage()
          prev.toggleClass("disabled")
      if (next.hasClass("disabled") && @hasNextPage()) || !@hasNextPage()
          next.toggleClass("disabled")
      
    ###
     * Render the pagination controls per the format attribute into the specified container nodes.
    ###
    render: =>
        totalRecords = @getTotalRecords()
        #rowsPerPage = +@get("rowsPerPage")
        containers = @get("containers")
        currentPage = @getCurrentPage()
      
        
        containers.find(".ex-pg-page").remove()
        nextEl = containers.find(".ex-pg-next")
        
        totalPages = @getTotalPages()
        
        # conditions to align active page by center
        to = currentPage + 4
        from = currentPage - 4
        
        if from <= 0
            to += Math.abs(from) + 1
            from = 1
        if to > totalPages
            from -= to - totalPages
            to = totalPages
      
        from = 1 if from <= 0
        to = totalPages if to > totalPages
       
        i = from
        while i <= to
          liEl = jQuery("<li />", class: "ex-pg-page").append(
            jQuery("<a />", href: "#", text: i)
          )
          
          liEl.addClass("active") if i is currentPage
          liEl.insertBefore(nextEl)
          liEl.data("page", i)
          
          i++
         
    getTotalRecords: ->
      return +@get("totalRecords")
    
    ###
     * Set the total number of records.
    ###
    setTotalRecords: (total) ->
        @set("totalRecords", total) unless @getTotalRecords() is total
    
    
    getRowsPerPage: ->
      return @get("rowsPerPage")
    
    ###
     * Set the number of rows per page.
    ###
    setRowsPerPage: (number) ->
      return @set("rowsPerPage", number)
         
    ###
     * Get the page number corresponding to the current record offset.
    ###
    getCurrentPage: ->
      return @get("currentPage")
      
    ###
     * Set the current page to the provided page number if possible.
     * Parameters:
     *  newPage <number> the new page number
    ###
    setPage: (newPage) ->
      if @hasPage(newPage)
          @set("currentPage", newPage)
    
    getTotalPages: ->
      totalPages = @getTotalRecords() / @getRowsPerPage()
      totalPages++ if totalPages > Math.floor(totalPages)
      Math.floor(totalPages)
    
    ###
     * Does the requested page have any records?
    ###
    hasPage: (page) ->
      return false if page < 1
      page <= @getTotalPages()
      
    ###
     * Are there records on the next page?
    ###
    hasNextPage: () ->
      @hasPage @getCurrentPage() + 1
      
    ###
     * Is there a page before the current page?
    ###
    hasPrevPage: () ->
      @hasPage @getCurrentPage() - 1
      
      
    ###
     *  Fires the pageChange event when the state attributes have changed
    ###
    _handleStateChange: ->
        totalPages = @getTotalPages()
        
        if totalPages <= 1           
            @get("containers").hide("fast") unless @get("alwaysVisible")
        else unless @get("alwaysVisible")
            @get("containers").show("fast") 
        
        if @getCurrentPage() > totalPages
            @setPage totalPages
        
        @render()
        @updateVisibility()
      
    ###
     *  Fires the pageChange event when the state attributes have changed
    ###
    _handlePageChange: (event) =>
    
      target = $(event.currentTarget)
      currentPage = @getCurrentPage()
      totalPages = @getTotalPages()
      
      page = target.data("page")
      
      if page is "prev"
          page = currentPage - 1
      else if page is "next"
          page = currentPage + 1
      else if page is "last"
          page = totalPages
    
      @setPage +page unless page is currentPage
      
    initEvents: ->
        @get("containers").on "click", "li", @_handlePageChange
        
        if select = @get("rowsPerPageSelect")
            select = jQuery select
            select.on "change", (event) =>
                @set "rowsPerPage", select.val()
                
            #@on "rowsPerPageChange", (value) =>
               # select.val value
      
    ###
     * Subscribes to instance attribute change events to automate certain behaviors.
    ###
    _selfSubscribe: ->
      
      @on "rowsPerPageChange", @_handleStateChange
      @on "totalRecordsChange", @_handleStateChange
      @on "currentPageChange", @render
      @on "currentPageChange", @updateVisibility
    
      
    _initUIComponents: ->
      ulEl = jQuery("<ul />", class: "ex-pg")
      ulEl.append(
        jQuery("<li />", class: "ex-pg-first").append(jQuery("<a />", href: "#", text: "First")).data("page", 1)
        jQuery("<li />", class: "ex-pg-prev").append(jQuery("<a />", href: "#", text: "Prev")).data("page", "prev")
        jQuery("<li />", class: "ex-pg-next").append(jQuery("<a />", href: "#", text: "Next")).data("page", "next")
        jQuery("<li />", class: "ex-pg-last").append(jQuery("<a />", href: "#", text: "Last")).data("page", "last")
      )
      
      @get("containers").empty().append(ulEl)
      
  
  
class Ex.Filter
    $.extend @prototype, Ex.AttributeProvider.prototype
    
    constructor: (config) ->
        @__init()
    
    filter: (element, index, array) ->
        
    isSelected: ->

class Ex.Filter.Search extends Ex.Filter
    constructor: (config) ->
        super 
        defaults =
            container: null
            filterFn: @_applyFilters
            valueUpdate: 'keydown' # keyup, keypress
            value: ''
            
        @cfg = $.extend(defaults, config)
        @cfg.container = jQuery @cfg.container
        @initEvents()
        
    initEvents: ->
        event = @get("valueUpdate")
        @get("container").on event, Ex.util.throttle((event) =>
            @set "value", jQuery(event.target).val()
        , 100)
        
    filter: (element, index, array) ->
        @get("filterFn")?(element, index, array)
        
    isSelected: ->
        !!@get("value")
        
    _applyFilters: (element, index, array) =>
        value = @get("value").toLowerCase()
        predicate = false
        for name, record of element
            if ~((record + "").toLowerCase().indexOf(value))
                predicate = true
                break
        predicate
                
        
        
Ex.util ?= {}  
# Throttling function calls
Ex.util.throttle = (fn, delay) ->
  timer = null
  ->
    context = this
    args = arguments
    clearTimeout timer
    timer = setTimeout(->
      fn.apply context, args
    , delay)
        
        