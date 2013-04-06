# define application namespace
window.Ex ?= {}

###
 * Ex.EventProvider is designed wrap CustomEvents in an interface that allows 
 * events to be subscribed to and fired by name
###
class Ex.EventProvider
    ###
     * Attach a handler to an event.
     * @param {String} event        An event name
     * @param {Function} handler    A function to execute each time the event is triggered.
    ###
    bind: (event, handler) ->
        @_events ?= {}
        @_events[event] ?= []
        @_events[event].push handler

    ###
     * Remove an event handler.
     * @param {String} event        An event name
     * @param {Function} handler    A function to execute each time the event is triggered.
    ###
    unbind: (event, handler) ->
        @_events ?= {}
        return if event of @_events is false
        @_events[event].splice @_events[event].indexOf(handler), 1

    ###
     * Execute all handlers and behaviors for the given event type.
     * @param {String} event        An event name
    ###
    trigger: (event) -> # , args...
        @_events ?= {}
        return  if event of @_events is false
        for event in @_events[event]
            event.apply @, Array::slice.call(arguments, 1)

    # Shortcuts
    emit: @::trigger
    on: @::bind
    off: @::unbind

###
 * Provides and manages Ex.AttributeProvider instances
###
class Ex.AttributeProvider
    jQuery.extend @prototype, Ex.EventProvider .prototype
    ###
     * Sets the value of a config.
    ###
    set: (name, value) ->
        @cfg ?= {}
        #if @cfg[name] isnt value
        @cfg[name] = value
        @trigger "#{name}Change", value

    ###
     * Returns the current value of the attribute.
    ###
    get: (name) ->
        @cfg ?= {}
        return @cfg[name]
