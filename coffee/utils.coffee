###
 * Utility Components
###
Ex.util ?= {}

###
 * Throttling function calls
###
Ex.util.throttle = (fn, delay) ->
    timer = null
    ->
        context = this
        args = arguments
        clearTimeout timer
        timer = setTimeout(->
            fn.apply context, args
        , delay)