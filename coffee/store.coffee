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
        configs ?= {}
        @cfg = configs

    ###
     * Set the data
     * @param {Object} data
    ###
    setData: (data) ->
        @_data = jQuery.extend [], data
        @trigger "onDataChange", @_data

    ###
     * Get the data
     * @return {Object}
    ###
    getData: () ->
        @_data

    ###
     * Compute data taking into account order
     * @return {Object}
    ###
    compute: (key, dir, callback) ->
        callback?(@_data)

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
 * Small helper class to make creating stores from Array data easier
 * @namespace Ex
 * @class ArrayStore
 * @extends Ex.Store
###
class Ex.ArrayStore extends Ex.Store
    paginator: null

    constructor: (configs) ->
        super configs
        @setData configs.data if configs.data

    ###
     * Compute data taking into account order
     * @return {Object}
    ###
    compute: (key, dir, callback) ->
        # sort the data
        data = @getData()

        data.sort (a, b) ->
            asc = dir is "ASC"
            val1 = a[key]
            val2 = b[key]
            if val1 < val2
                return if asc then -1 else 1
            if val1 is val2
                return 0
            else
                return if asc then 1 else -1

        callback?(data)

###
 * Small helper class to make creating stores from HTML table easier
 * @namespace Ex
 * @class TableStore
 * @extends Ex.ArrayStore
###
class Ex.TableStore extends Ex.ArrayStore

    ###
     * @constructor
     * @param {Object} config  Contains: 
     * - container
     * - field - An array with fields names
    ###
    constructor: (configs) ->
        fields = configs.fields
        data = []
        jQuery("tbody tr", configs.container).each (key, rowEl) ->
            cells = $(rowEl).find(">td")
            obj = {}
            for field, i in fields
                obj[field] = cells.eq(i).text()
            data.push obj

        configs.data = data
        
        super configs

###
 * Remove store
###
class Ex.RemoteStore extends Ex.Store
    paginator: null

    ###
     * @constructor
     * @param {Object} configs  Contains: 
     *   - url
    ###
    constructor: (configs) ->
        super configs
        @paginator = configs?.paginator
        console.warning "You should specity the url" unless configs.url

    ###
     * Compute data taking into account order
     * @return {Object}
    ###
    compute: (key, dir, callback) ->
        data = {}

        data.key = key
        data.dir = dir

        $.ajax
            url: @get("url")
            type: "POST"
            data: data
            dataType: "json"
            success:(response, textStatus, jqXHR) =>
                @setData response
                callback?(response.records)