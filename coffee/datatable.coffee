###
 * DataTable class
 * The constructor accepts the following parameters:
 *  - container {HTMLElement} Container element for the TABLE.
 *  - configs {Object} (optional) Object literal of configuration values.
###
class Ex.DataTable
    $.extend @prototype, Ex.AttributeProvider.prototype
    # data that that ware rendered to the datatable
    _data: []

    ###
     * @constructor
    ###
    constructor: (container, configs) ->
        defaults =
            paginator: null
            columns: [] # Array of object literal Column definitions.
            store: null # DataSource instance
            scrollable: false
            filters: []
            sortedBy:
                key: null,
                dir: "ASC"

        @container = jQuery(container).empty().get(0)
        @cfg = $.extend(defaults, configs)

        @render()
        @initEvents()

    ###
     * Get data
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
        @trigger "beforeAddColumn", @, column, index
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
                @trigger "beforeRemoveColumn", @, column, key
                columns.splice i,1
                jQuery(".ex-dt-col-#{key}").remove()

    ###
     * Hides the column.
     * @param {String} key - the key of the column
    ###
    showColumn: (key) ->
        @trigger "beforeShowColumn", @, key
        jQuery(".ex-dt-col-#{key}").show()

    ###
     * Hides the column.
     * @param {String} key - the key of the column
    ###
    hideColumn: (key) ->
        @trigger "beforeHideColumn", @, key
        jQuery(".ex-dt-col-#{key}").hide()

    ###
     * Sorts given column.
     * @param {Object} column
     * @param {String} dir - ASC or DESC
    ###
    sortColumn: (column, dir) ->
        @trigger "beforeSortColumn", @, column, dir
        @set("sortedBy", key: column.key, dir: dir)
        $container = jQuery @container
        $thEl = jQuery column.thEl

        $thEl.addClass("ex-dt-#{dir.toLowerCase()}").siblings().removeClass("ex-dt-asc ex-dt-desc")
        @refresh()

    ###
     * Init events
    ###
    initEvents: ->
        # listen paginator events
        if paginator = @get("paginator")
            paginator.on "currentPageChange", @refresh
            paginator.on "rowsPerPageChange", @refresh

        # listen paginator events
        if paginator
            @getStore().on "onDataChange", (data) ->
                if data?.totalRecords
                    paginator.setTotalRecords data.totalRecords
                else
                    paginator.setTotalRecords data.length

        # listen filters events
        for filter in @get("filters")
            filter.on "valueChange", @refresh

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
        @trigger "beforeRenderColumns", @
        @theadEl.innerHTML = ''

        theadRowEl = @theadEl.insertRow 0
        columns = @get("columns")
        sortedBy = @cfg.sortedBy

        for column, i in columns
            # create the th element
            thEl = theadRowEl.appendChild document.createElement("th")
            thEl.exData =
                columnIndex: i
            thEl.width = column.width if column.width

            classes = ["ex-dt-col-#{column.key}"]
            # set as sortable by default
            column.sortable = true unless column.sortable?

            # add css classes to th element
            if column.sortable
                classes.push("ex-dt-sortable") 
                sortedBy.key = column.key unless sortedBy.key

            # add classes to the hidden columns
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
        @trigger "beforeTElements", @
        # build table structure
        @theadEl = @container.appendChild @container.createTHead()
        @tbodyEl = @container.appendChild @container.createTBody()
        @renderColumns()

        sortedBy = @get("sortedBy")
        if sortedBy.key
            @sortColumn(@getColumn("key", sortedBy.key), sortedBy.dir)
        else
            @refresh()

    ###
     * Re-render records in the datatable
    ###
    refresh: =>
        @trigger "beforeRefresh", @
        sortedBy = @cfg.sortedBy
        #tore = @getStore()
        @getStore().compute sortedBy.key, sortedBy.dir, (storeData) =>
            columns = @get("columns")
            #sortedBy = @get("sortedBy")
            rowFormatter = @get("rowFormatter")
            paginator = @get("paginator")
            filters = @get("filters")

            # data filtering
            for filter in filters
                if filter.isSelected()
                    storeData = storeData.filter (element, index, array)->
                        filter.filter(element, index, array)

            if paginator
                from = (paginator.getCurrentPage() - 1) * paginator.getRowsPerPage()
                to = paginator.getCurrentPage() * paginator.getRowsPerPage()

            storeData = @_data = storeData.slice from, to

            @tbodyEl.innerHTML = ''

            for record, i in storeData
                trEl = @tbodyEl.insertRow i
                rowFormatter?(trEl, record)
                trEl.className = "ex-dt-#{if i % 2 then 'odd' else 'even'}"

                for column, j in columns
                    tdEl = trEl.insertCell j
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

            @trigger "afterRefresh", @

    ###
     * Invokes when a cell has a click.
     * @param {Object} event - the event object
    ###
    onCellClick: (event) =>
        tdEl = event.currentTarget
        columns = @get("columns")
        store = @get("store")

        data = @getData(tdEl.parentNode.rowIndex)
        column = columns[tdEl.cellIndex]
        @trigger "onCellClick",
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
        @trigger "onRowClick",
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

        @trigger "onThClick",
            event: event
            column: column
            store: store = @get("store")

        if column.sortable
            dir = if @get("sortedBy").dir is "ASC" then "DESC" else "ASC"
            # Update UI via sortedBy
            @sortColumn column, dir
        
        