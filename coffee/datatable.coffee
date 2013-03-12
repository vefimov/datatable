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

    _data: []

    ###
     * @constructor
    ###
    constructor: (container, configs) ->
        defaults =
            paginator: null
            columns: [] # Array of object literal Column definitions.
            store: null # DataSource instance
            filters: []
            sortedBy:
                key: null,
                dir: "ASC"

        @container = jQuery(container).empty().get(0)
        @cfg = $.extend(defaults, configs)

        @render()
        @initEvents()

    ###
     * Get data by index
     * @param {Number} (Optional) index
     * @return {Object}
    ###
    getData: (index) ->
        return @_data[index] if index
        @_data

    ###
     * Inserts given Column at the index if given, otherwise at the end
     * @param {Object} column
     * @param {Number} index - (Optional) New tree index
    ###
    addColumn: (column, index) ->
        columns = @get("columns")
        index = columns.length unless index
        columns.splice index, 0, column
        @renderColumns()
        @render()

    ###
     * Removes the column.
     * @param {String} key - the key of the column
    ###
    removeColumn: (key) ->
        columns = @get("columns")
        for column, i in columns
            if column?.key is key
                columns.splice i,1
                jQuery(".ex-dt-col-#{key}").remove()

    ###
     * Hides the column.
     * @param {String} key - the key of the column
    ###
    showColumn: (key) ->
        jQuery(".ex-dt-col-#{key}").show()

    ###
     * Hides the column.
     * @param {String} key - the key of the column
    ###
    hideColumn: (key) ->
        jQuery(".ex-dt-col-#{key}").hide()

    ###
     * Sorts given column.
     * @param {Object} column
     * @param {String} dir - ASC or DESC
    ###
    sortColumn: (column, dir) ->
        @set("sortedBy", key: column.key, dir: dir)
        $(column.thEl).addClass("ex-dt-#{dir.toLowerCase()}")
            .parent().find(".ex-dt-asc, .ex-dt-desc").removeClass("ex-dt-asc ex-dt-desc")

        @getStore().sort column.key, dir
        @refresh()

    ###
     * Init events
    ###
    initEvents: ->
        # listen paginator events
        if paginator = @get("paginator")
            paginator.on "currentPageChange", @refresh()
            paginator.on "rowsPerPageChange", @refresh()

        # listen paginator events
        if paginator
            @getStore().on "onDataChange", (data) ->
                paginator.setTotalRecords data.length

        # listen filters events
        for filter in @get("filters")
            filter.on "valueChange", @refresh()

        # add handler to th, tr, td elements
        jQuery(@container).on "click", "thead th", @onThClick
        jQuery(@container).on "click", "tbody tr", @onRowClick
        jQuery(@container).on "click", "tbody td", @onCellClick

    ###
     * Find column by attribute name and its value
     * @param {String} attrName - attribute by which you want to search сolumn
     * @param {String} attrValue - value of attribute
     * @return {Object|null}
    ###
    getColumn: (attrName, attrValue) ->
        columns = @get("columns")
        for column in columns
            return column if column[attrName] is attrValue
        return null

    ###
     * Get store instance
     * @return {Ex.Store}
    ###
    getStore: ->
        @get("store")

    ###
     * Render the TH elements
    ###
    renderColumns: ->
        @theadEl.innerHTML = ''

        theadRowEl = @theadEl.insertRow 0
        columns = @get("columns")

        for column, i in columns
            # create the th element
            thEl = theadRowEl.appendChild document.createElement("th")
            thEl.exData =
                columnIndex: i
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

            column.thEl = thEl
            theadRowEl.appendChild thEl

        @theadEl.appendChild theadRowEl

    ###
     * Renders the view with existing records
    ###
    render: =>
        # build table structure
        @theadEl = @container.appendChild @container.createTHead()
        @tbodyEl = @container.appendChild @container.createTBody()
        @renderColumns()

        sortedBy = @get("sortedBy")
        if sortedBy.key
            @sortColumn(@getColumn("key", sortedBy.key), sortedBy.dir)
        else
            @refresh()

    refresh: ->
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

        if paginator
            from = (paginator.getCurrentPage() - 1) * paginator.getRowsPerPage()
            to = paginator.getCurrentPage() * paginator.getRowsPerPage()

        storeData = @_data = storeData.slice from, to

        @tbodyEl.innerHTML = ''

        for record, i in storeData
            trEl = @tbodyEl.insertRow i
            #trEl.exData = record:recor
            ###trEl.exData =
                dataIndex: i###
            rowFormatter?(trEl, record)
            trEl.className = "ex-dt-#{if i % 2 then 'odd' else 'even'}"

            for column, j in columns
                tdEl = trEl.insertCell j
                ###tdEl.exData =
                    columnIndex: j###

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

        console.timeEnd("Rendering data")

    ###
     * Invokes when a cell has a click.
     * @param {Object} event - the event object
    ###
    onCellClick: (event) =>
        tdEl = event.currentTarget
        columns = @get("columns")
        store = @get("store")
        data = @getData(tdEl.parentChild.rowIndex)
        column = columns[tdEl.cellIndex]
        @emit "onCellClick",
            event: event
            column: column
            store: store
            data: data

    ###
     * Invokes when a row has a click.
     * @param {Object} event - the event object
    ###
    onRowClick: (event) =>
        trEl = event.currentTarget
        data = @_data[trEl.rowIndex]
        store = @get("store")
        @emit "onRowClick",
            event: event
            store: store = @get("store")
            data: data

    ###
     * Invokes when a col has a click.
     * @param {Object} event - the event object
    ###
    onThClick: (event) =>
        thEl = event.currentTarget
        columns = @get("columns")
        column = columns[thEl.cellIndex]

        @emit "onThClick",
            event: event
            column: column
            store: store = @get("store")

        if column.sortable
            dir = if @get("sortedBy").dir is "ASC" then "DESC" else "ASC"
            # Update UI via sortedBy
            @sortColumn column, dir

### ********************************************************************** ###
### ********************************************************************** ###
### ********************************************************************** ###

###
 * The Store class encapsulates a client side cache of Model objects
 * The constructor accepts the following parameters:
 *  - configs {Object} (optional) Object literal of configuration values.
###
class Ex.Store
    $.extend @prototype, Ex.AttributeProvider.prototype

    _data: []

    ###
     * @constructor
    ###
    constructor: (configs) ->
        @setData configs.data
        @cfg = {}

    ###
     * Set the data
     * @param {Object} data
    ###
    setData: (data) ->
        @_data = jQuery.extend [], data
        @emit "onDataChange", @_data

    ###
     * Get the data
     * @param {Number} index
     * @return {Object}
    ###
    getData: (index) ->
        return @_data if typeof(index) isnt "number"
        @_data[index]

    ###
     * Remove record from store
     * @param {Number, Function}
    ###
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
    ###
     * Sort the data
     * @param {String} key - the key by with sort data
     * @param {String} dir - ASC or DESC
    ###
    sort: (key, dir) ->


###
 * Small helper class to make creating stores from Array data easier
 * @namespace Ex
 * @class ArrayStore
 * @extends Ex.Store
###
class Ex.ArrayStore extends Ex.Store
    constructor: (configs) ->
        super

    ###
     * Sort the data
     * @param {String} key - the key by with sort data
     * @param {String} dir - ASC or DESC
    ###
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
 * Small helper class to make creating stores from HTML table easier
 * @namespace Ex
 * @class TableStore
 * @extends Ex.ArrayStore
###
class Ex.TableStore extends Ex.ArrayStore
    constructor: (configs) ->
        fields = config.fields
        data = []
        jQuery("tbody tr", configs.container).each (key, rowEl) ->
            cells = $(rowEl).find(">td")
            for field, i in fields
                obj = {}
                obj[field] = cells.eq(i).text()
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
        
        