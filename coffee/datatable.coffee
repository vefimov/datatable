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
    jQuery.extend @prototype, EventEmitter.prototype
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
        defaults =
            paginator: null
            columns: [] # Array of object literal Column definitions.
            store: null # DataSource instance
            filters: []
            #fields: null # list of the fields
            sortedBy:
                key: null,
                dir: "ASC"

        @container = jQuery(container).empty().get(0)
        @cfg = $.extend(defaults, configs)

        @theadEl = @container.appendChild @container.createTHead()
        @tbodyEl = @container.appendChild @container.createTBody()
        @renderColumns()

        sortedBy = @get("sortedBy")
        if sortedBy.key
            @sortColumn(@getColumn("key", sortedBy.key), sortedBy.dir)



        @render()
        @initEvents()

    initEvents: ->
        if paginator = @get("paginator")
            paginator.on "currentPageChange", @render
            paginator.on "rowsPerPageChange", @render

        @getStore().on "onDataChange", (data) ->
            if paginator
                paginator.setTotalRecords data.length

        #@render()

        for filter in @get("filters")
            filter.on "valueChange", @render

        jQuery(@container).on "click", "thead th", @onThClick
        jQuery(@container).on "click", "tbody tr", @onRowClick
        jQuery(@container).on "click", "tbody td", @onCellClick


    onCellClick: (event) =>
        tdEl = event.currentTarget
        @emit "onCellClick",
            event: event
            column: tdEl.exData.column
            record: tdEl.exData.record

    onRowClick: (event) =>
        trEl = event.currentTarget
        @emit "onRowClick",
            event: event
            column: trEl.exData.column
            record: trEl.exData.record

    onThClick: (event) =>
        thEl = event.currentTarget
        column = thEl.exData.column

        @emit "onThClick",
            event: event
            column: column

        if column.sortable
            dir = if @get("sortedBy").dir is "ASC" then "DESC" else "ASC"
            # Update UI via sortedBy
            @sortColumn column, dir

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
        #@theadEl = @container.createTHead()
        #@tbodyEl = @container.createTBody()
        jQuery(@theadEl).empty() #.innerHTML = ''

        theadRowEl = @theadEl.insertRow 0
        columns = @get("columns")

        for column in columns
            thEl = theadRowEl.appendChild document.createElement("th")
            thEl.exData = column: column
            thEl.width = column.width if column.width

            classes = ["ex-dt-col-#{column.key}"]
            # add css classes to th element
            classes.push("ex-dt-sortable") if column.sortable
            if column.hidden
                classes.push("ex-dt-hidden")
                thEl.style.display = "none"
            classes.push("ex-dt-col-#{column.key}")

            thEl.className = classes.join " "
            divEl = document.createElement("div")
            divEl.className = "ex-dt-cell-inner"
            divEl.appendChild document.createTextNode column.label
            thEl.appendChild divEl
            #thEl.on "click", @onEventSortColumn.bind null, column

            column.thEl = thEl
            theadRowEl.appendChild thEl

        @theadEl.appendChild theadRowEl

    ###
     * Renders the view with existing records
    ###
    render: =>
        console.time("Rendering data")
        #tore = @getStore()
        storeData = @getStore().getData()
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
        to = 10
        #storeData.length

        if paginator
            from = (paginator.getCurrentPage() - 1) * paginator.getRowsPerPage()
            to = paginator.getCurrentPage() * paginator.getRowsPerPage()

        storeData = storeData.slice from, to

        #@tbodyEl.empty()

        #tbodyEl = @tbodyEl
        jQuery(@tbodyEl).empty() #.innerHTML = ''

        for record, i in storeData
            trEl = @tbodyEl.insertRow i
            #trEl.exData = record:recor
            trEl.exData =
                record: record
            rowFormatter?(trEl, record)
            trEl.className = "ex-dt-#{if i % 2 then 'odd' else 'even'}"

            for column, j in columns
                tdEl = trEl.insertCell j
                tdEl.exData =
                    columnIndex: j
                ###tdEl.exData =
                    column: column
                    record: record###
                tdEl.className = "ex-dt-col-#{column.key}"

                # call cell formatter
                if typeof column.formatter is "function"
                    column.formatter tdEl, column, record
                else
                    divEl = document.createElement "div"
                    divEl.className = "ex-dt-cell-inner"
                    divEl.appendChild document.createTextNode(record[column.key])
                    tdEl.appendChild divEl

                if column.hidden
                    tdEl.className += " hidden"
                    tdEl.style.display = "none"


            @tbodyEl.appendChild trEl

        ###for record in storeData
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
          @tbodyEl.append trEl###

        console.timeEnd("Rendering data")

    ###
     * Custom event handler to sort Column.
    ###
    ###onEventSortColumn: (column) =>
      if column.sortable
        dir = if @get("sortedBy").dir is "ASC" then "DESC" else "ASC"
        # Update UI via sortedBy
        @sortColumn column, dir###

    ###
     * Sorts given Column. 
    ###
    sortColumn: (column, dir) ->
        @set("sortedBy", key: column.key, dir: dir)
        $(column.thEl).addClass("ex-dt-#{dir.toLowerCase()}")
            .parent().find(".ex-dt-asc, .ex-dt-desc").removeClass("ex-dt-asc ex-dt-desc")

        @getStore().sort column.key, dir
    #@render()


    showColumn: (key) ->
        jQuery(".ex-dt-col-#{key}").show()

    hideColumn: (key) ->
        jQuery(".ex-dt-col-#{key}").hide()

    removeColumn: (key) ->
        columns = @get("columns")
        for column, i in columns
            if column.key is key
                columns.splice i,1
                @hideColumn(key)

    addColumn: (column, index=0) ->
        columns = @get("columns")
        columns.splice index, 0, column
        @renderColumns()
        @render()

###getColumnByKey: (key) ->
    for column in @get("columns")
        if column.key is key
            return column###


###class Ex.DataTable.Column
    $.extend @prototype, Ex.AttributeProvider.prototype
    constructor: ->###


###
 * The Store class encapsulates a client side cache of Model objects
###
class Ex.Store
    $.extend @prototype, Ex.AttributeProvider.prototype

    _data: []

    constructor: (configs) ->
        @setData configs.data
        @cfg = {}

    setData: (data) ->
        @_data = jQuery.extend [], data
        @emit "onDataChange", @_data

    getData: (index) ->
        return @_data if typeof(index) isnt "number"
        @_data[index]

    remove: (item) ->
        switch typeof(item)
            when "number"
                @_data.splice item, 1
            when "function"
                for record, i in @data
                    result = item(record,i)
                    if result is true
                        @_data.splice index, 1
                    else if result is false
                        break
#sortData: (key, dir) ->


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

        @emit "onDataChange", @getData()

###
 * 
###
class Ex.TableStore extends Ex.ArrayStore
    constructor: (configs) ->
        #config.fields  
        #
        fields = config.fields
        data = []
        jQuery("tbody tr", configs.container).each (key, rowEl) ->
            cells = $(rowEl).find(">td")
            for field in fields
                obj = {}
                obj[field] = cells.eq(_i).text()
                data.push obj
        configs =
            data: data
        super config


class Ex.RemoteStore extends Ex.ArrayStore
    constructor: (configs) ->
        super config

###
 * Paginator 
 * Parameters:
 *    config <Object> Object literal to set instance and ui component configuration.
###
class Ex.Paginator
    $.extend @prototype, Ex.AttributeProvider.prototype

    #_currentPage: 1

    constructor: (@config) ->
        defaults =
            rowsPerPage: 30
            rowsPerPageSelect: null
            container: ''
            totalRecords: 0
            currentPage: 1
            alwaysVisible: false

        config = $.extend(defaults, config)
        config.container = $(config.container).eq(0)
        #config.rowsPerPageSelect = $(config.containers)
        @cfg = config

        @_initUIComponents()
        @initEvents()
        @_selfSubscribe()
        #@updateState()
        @setPage 1

    updateVisibility: =>
        container = @get("container")
        prev = container.find(".ex-pg-first, .ex-pg-prev")
        next = container.find(".ex-pg-last, .ex-pg-next")

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
        container = @get("container")
        currentPage = @getCurrentPage()


        container.find(".ex-pg-page").remove()
        nextEl = container.find(".ex-pg-next").get(0)
        ulEl = container.find(">ul").get(0)

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
            liEl = document.createElement "li"
            liEl.className = "ex-pg-page"

            linkEl = document.createElement "a"
            linkEl.href = "#"
            linkEl.textContent = i

            liEl.className += " active" if i is currentPage
            liEl.setAttribute "data-page", i
            liEl.appendChild linkEl

            #console.log ulEl
            #ulEl.appendChild liEl
            ulEl.insertBefore(liEl, nextEl)

            ###liEl = jQuery("<li />", class: "ex-pg-page").append(
              jQuery("<a />", href: "#", text: i)
            )
            
            liEl.addClass("active") if i is currentPage
            liEl.insertBefore(nextEl)
            liEl.data("page", i)###

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
            @get("container").hide("fast") unless @get("alwaysVisible")
        else unless @get("alwaysVisible")
            @get("container").show("fast")

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
        @get("container").on "click", "li", @_handlePageChange

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

        @get("container").empty().append(ulEl)


class Ex.Filter
    $.extend @prototype, Ex.AttributeProvider.prototype

    constructor: (config) ->


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
        
        