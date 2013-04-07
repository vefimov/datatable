###
 * The Paginator Control allows you to reduce the page size and render time of your site 
 * or web application by breaking up large data sets into discrete pages. 
 * Parameters:
 *    config <Object> Object literal to set instance and ui component configuration.
###
class Ex.Paginator
    jQuery.extend @prototype, Ex.AttributeProvider.prototype

    #_currentPage: 1

    constructor: (@config) ->
        defaults =
            rowsPerPage: 30
            rowsPerPageSelect: null
            container: ''
            totalRecords: 0
            currentPage: 1
            alwaysVisible: false

        @cfg = jQuery.extend(defaults, config)
        @cfg.container = jQuery(@cfg.container).eq(0)

        @_initUIComponents()
        @_initEvents()
        @_selfSubscribe()
        @render()

    ### 
     * Hides the containers if there is only one page of data and attribute alwaysVisible is false. 
    ###
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
            ulEl.insertBefore(liEl, nextEl)

            i++

    ###
     * Get the total number of records.
     * @return {Number}
    ###
    getTotalRecords: ->
        return +@get("totalRecords")

    ###
     * Set the total number of records.
    ###
    setTotalRecords: (total) ->
        @set("totalRecords", total) unless @getTotalRecords() is total

    ###
     * Get the number of rows per page.
     * @return {Number}
    ###
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

    ###
     * Get the total number of pages in the data set according to the current rowsPerPage and totalRecords values.
     * @return {Number}
    ###
    getTotalPages: ->
        totalPages = @getTotalRecords() / @getRowsPerPage()
        totalPages++ if totalPages > Math.floor(totalPages)
        Math.floor(totalPages)

    ###
     * Does the requested page have any records?
     * @return {Bool} 
    ###
    hasPage: (page) ->
        return false if page < 1
        page <= @getTotalPages()

    ###
     * Are there records on the next page?
    * @return {Bool} 
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
    _handleStateChange: =>
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
        target = jQuery(event.currentTarget)
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

    _initEvents: ->
        @get("container").on "click", "li", @_handlePageChange

        if select = @get("rowsPerPageSelect")
            select = jQuery select
            select.on "change", (event) =>
                @set "rowsPerPage", select.val()

    ###
     * Subscribes to instance attribute change events to automate certain behaviors.
    ###
    _selfSubscribe: ->
        @on "rowsPerPageChange", @_handleStateChange
        @on "totalRecordsChange", @_handleStateChange
        @on "currentPageChange", @render
        @on "currentPageChange", @updateVisibility

    ###
     * Renders the paginator UI 
    ###
    _initUIComponents: ->
        ulEl = jQuery("<ul />", class: "ex-pg")
        ulEl.append(
            jQuery("<li />", class: "ex-pg-first").append(jQuery("<a />", href: "#", text: "First")).data("page", 1)
            jQuery("<li />", class: "ex-pg-prev").append(jQuery("<a />", href: "#", text: "Prev")).data("page", "prev")
            jQuery("<li />", class: "ex-pg-next").append(jQuery("<a />", href: "#", text: "Next")).data("page", "next")
            jQuery("<li />", class: "ex-pg-last").append(jQuery("<a />", href: "#", text: "Last")).data("page", "last")
        )

        @get("container").css(display:"none").empty().append(ulEl)