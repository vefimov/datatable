###
 * Base class for filters. 
###
class Ex.Filter
    $.extend @prototype, Ex.AttributeProvider.prototype

    constructor: (config) ->

    filter: (element, index, array) ->

    isSelected: ->

###
 * Search fiter. 
###
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

    ###
     * 
    ###
    initEvents: ->
        event = @get("valueUpdate")
        @get("container").on event, Ex.util.throttle((event) =>
            @set "value", jQuery(event.target).val()
        , 100)

    ###
     * Filter the data
    ###
    filter: (element, index, array) ->
        @get("filterFn")?(element, index, array)

    ###
     * Check that the filter has been selected
     * @return {Bool}
    ###
    isSelected: ->
        !!@get("value")

    ###
     * Method to filter the data
    ###
    _applyFilters: (element, index, array) =>
        value = @get("value").toLowerCase()
        predicate = false
        for name, record of element
            if ~((record + "").toLowerCase().indexOf(value))
                predicate = true
                break
        predicate