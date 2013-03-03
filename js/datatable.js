// Generated by CoffeeScript 1.5.0

/*
 * This work is licensed under the Creative Commons Attribution-NoDerivs 3.0 Unported License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nd/3.0/ or send a
 * letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
*/


(function() {
  var _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if ((_ref = window.Ex) == null) {
    window.Ex = {};
  }

  /*
   * Provides and manages Ex.AttributeProvider instances
  */


  Ex.AttributeProvider = (function() {

    function AttributeProvider() {}

    AttributeProvider.prototype.__init = function() {
      this.cfg = {};
      return this.__eventEmitter = jQuery(this);
    };

    /*
     * Execute all handlers and behaviors attached to the matched elements for the given event type.
    */


    AttributeProvider.prototype.emit = function(evt, data) {
      return this.__eventEmitter.trigger(evt, data);
    };

    /*
     * Attach a handler to an event for the elements. The handler is executed at most once per element.
    */


    AttributeProvider.prototype.once = function(evt, handler) {
      return this.__eventEmitter.one(evt, handler);
    };

    /*
     * Attach an event handler function for one or more events to the selected elements.
    */


    AttributeProvider.prototype.on = function(evt, handler) {
      return this.__eventEmitter.bind(evt, handler);
    };

    /*
     * Remove an event handler.
    */


    AttributeProvider.prototype.off = function(evt, handler) {
      return this.__eventEmitter.unbind(evt, handler);
    };

    /*
     * Sets the value of a config.
    */


    AttributeProvider.prototype.set = function(name, value) {
      this.emit("" + name + "Change", value);
      return this.cfg[name] = value;
    };

    /*
     * Returns the current value of the attribute.
    */


    AttributeProvider.prototype.get = function(name) {
      return this.cfg[name];
    };

    return AttributeProvider;

  })();

  /*
   * DataTable class
   * The constructor accepts the following parameters:
   *  - container {HTMLElement} Container element for the TABLE.
   *  - configs {Object} (optional) Object literal of configuration values.
  */


  Ex.DataTable = (function() {

    $.extend(DataTable.prototype, Ex.AttributeProvider.prototype);

    function DataTable(container, configs) {
      this.onEventSortColumn = __bind(this.onEventSortColumn, this);
      var defaults;
      this.__init();
      defaults = {
        columns: [],
        store: null,
        fields: null,
        sortedBy: {
          key: null,
          asc: true
        }
      };
      this.container = jQuery(container);
      this.cfg = $.extend(defaults, configs);
      this.theadEl = jQuery("<thead />");
      this.tbodyEl = jQuery("<tbody />");
      this.container.empty().append(this.theadEl).append(this.tbodyEl);
    }

    DataTable.prototype.getStore = function() {
      return this.get("store");
    };

    DataTable.prototype.renderColumns = function() {
      var column, columns, thEl, theadRowEl, _i, _len;
      theadRowEl = jQuery("<tr />");
      columns = this.get("columns");
      for (_i = 0, _len = columns.length; _i < _len; _i++) {
        column = columns[_i];
        thEl = jQuery("<th />");
        thEl.append(jQuery("<div />").text(column.label));
        thEl.on("click", this.onEventSortColumn.bind(null, column));
        theadRowEl.append(thEl);
      }
      return this.theadEl.append(theadRowEl);
    };

    /*
     * Renders the view with existing records
    */


    DataTable.prototype.render = function() {
      var column, columns, record, storeData, tdEl, trEl, _i, _j, _len, _len1, _results;
      storeData = this.getStore().getData();
      columns = this.get("columns");
      _results = [];
      for (_i = 0, _len = storeData.length; _i < _len; _i++) {
        record = storeData[_i];
        trEl = jQuery("<tr />");
        for (_j = 0, _len1 = columns.length; _j < _len1; _j++) {
          column = columns[_j];
          tdEl = jQuery("<td />");
          tdEl.append(jQuery("<div />").text(record[column.key]));
          trEl.append(tdEl);
        }
        _results.push(this.tbodyEl.append(trEl));
      }
      return _results;
    };

    /*
     * Custom event handler to sort Column.
    */


    DataTable.prototype.onEventSortColumn = function(column, event) {
      var b;
      if (column.sortable) {
        return b = 1;
      }
    };

    return DataTable;

  })();

  /*
   * The Store class encapsulates a client side cache of Model objects
  */


  Ex.Store = (function() {

    $.extend(Store.prototype, Ex.AttributeProvider.prototype);

    function Store(configs) {
      this.__init();
      this.cfg = configs;
    }

    Store.prototype.getData = function() {
      return this.get("data");
    };

    return Store;

  })();

  /*
   * Small helper class to make creating stores from Array data easier
  */


  Ex.ArrayStore = (function(_super) {

    __extends(ArrayStore, _super);

    function ArrayStore(configs) {
      ArrayStore.__super__.constructor.apply(this, arguments);
    }

    return ArrayStore;

  })(Ex.Store);

}).call(this);
