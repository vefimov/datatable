// Generated by CoffeeScript 1.6.1
(function() {
  var _ref, _ref1,
    _this = this,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  if ((_ref = window.Ex) == null) {
    window.Ex = {};
  }

  /*
   * Ex.EventProvider is designed wrap CustomEvents in an interface that allows 
   * events to be subscribed to and fired by name
  */


  Ex.EventProvider = (function() {

    function EventProvider() {}

    /*
     * Attach a handler to an event.
     * @param {String} event        An event name
     * @param {Function} handler    A function to execute each time the event is triggered.
    */


    EventProvider.prototype.bind = function(event, handler) {
      var _base, _ref1, _ref2;
      if ((_ref1 = this._events) == null) {
        this._events = {};
      }
      if ((_ref2 = (_base = this._events)[event]) == null) {
        _base[event] = [];
      }
      return this._events[event].push(handler);
    };

    /*
     * Remove an event handler.
     * @param {String} event        An event name
     * @param {Function} handler    A function to execute each time the event is triggered.
    */


    EventProvider.prototype.unbind = function(event, handler) {
      var _ref1;
      if ((_ref1 = this._events) == null) {
        this._events = {};
      }
      if (event in this._events === false) {
        return;
      }
      return this._events[event].splice(this._events[event].indexOf(handler), 1);
    };

    /*
     * Execute all handlers and behaviors for the given event type.
     * @param {String} event        An event name
    */


    EventProvider.prototype.trigger = function(event) {
      var _i, _len, _ref1, _ref2, _results;
      if ((_ref1 = this._events) == null) {
        this._events = {};
      }
      if (event in this._events === false) {
        return;
      }
      _ref2 = this._events[event];
      _results = [];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        event = _ref2[_i];
        _results.push(event.apply(this, Array.prototype.slice.call(arguments, 1)));
      }
      return _results;
    };

    EventProvider.prototype.emit = EventProvider.prototype.trigger;

    EventProvider.prototype.on = EventProvider.prototype.bind;

    EventProvider.prototype.off = EventProvider.prototype.unbind;

    return EventProvider;

  })();

  /*
   * Provides and manages Ex.AttributeProvider instances
  */


  Ex.AttributeProvider = (function() {

    function AttributeProvider() {}

    jQuery.extend(AttributeProvider.prototype, Ex.EventProvider.prototype);

    /*
     * Sets the value of a config.
    */


    AttributeProvider.prototype.set = function(name, value) {
      var _ref1;
      if ((_ref1 = this.cfg) == null) {
        this.cfg = {};
      }
      this.cfg[name] = value;
      return this.trigger("" + name + "Change", value);
    };

    /*
     * Returns the current value of the attribute.
    */


    AttributeProvider.prototype.get = function(name) {
      var _ref1;
      if ((_ref1 = this.cfg) == null) {
        this.cfg = {};
      }
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

    jQuery.extend(DataTable.prototype, Ex.AttributeProvider.prototype);

    DataTable.prototype._data = [];

    /*
     * @constructor
    */


    function DataTable(container, configs) {
      var defaults,
        _this = this;
      this.onThClick = function(event) {
        return DataTable.prototype.onThClick.apply(_this, arguments);
      };
      this.onRowClick = function(event) {
        return DataTable.prototype.onRowClick.apply(_this, arguments);
      };
      this.onCellClick = function(event) {
        return DataTable.prototype.onCellClick.apply(_this, arguments);
      };
      this.refresh = function() {
        return DataTable.prototype.refresh.apply(_this, arguments);
      };
      this.render = function() {
        return DataTable.prototype.render.apply(_this, arguments);
      };
      defaults = {
        paginator: null,
        columns: [],
        store: null,
        scrollable: false,
        filters: [],
        sortedBy: {
          key: null,
          dir: "ASC"
        }
      };
      this.container = jQuery(container).empty().get(0);
      this.cfg = jQuery.extend(defaults, configs);
      this.initEvents();
      this.render();
    }

    /*
     * Get data
     * @param {Number} (Optional) index
     * @return {Object}
    */


    DataTable.prototype.getData = function(index) {
      if (index) {
        return this._data[index];
      }
      return this._data;
    };

    /*
     * Inserts given Column at the index if given, otherwise at the end
     * @param {Object} column
     * @param {Number} index - (Optional) New tree index
    */


    DataTable.prototype.addColumn = function(column, index) {
      var columns;
      this.trigger("beforeAddColumn", this, column, index);
      columns = this.get("columns");
      if (!index) {
        index = columns.length;
      }
      columns.splice(index, 0, column);
      this.renderColumns();
      return this.render();
    };

    /*
     * Removes the column.
     * @param {String} key - the key of the column
    */


    DataTable.prototype.removeColumn = function(key) {
      var column, columns, i, _i, _len, _results;
      columns = this.get("columns");
      _results = [];
      for (i = _i = 0, _len = columns.length; _i < _len; i = ++_i) {
        column = columns[i];
        if ((column != null ? column.key : void 0) === key) {
          this.trigger("beforeRemoveColumn", this, column, key);
          columns.splice(i, 1);
          _results.push(jQuery(".ex-dt-col-" + key).remove());
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    /*
     * Hides the column.
     * @param {String} key - the key of the column
    */


    DataTable.prototype.showColumn = function(key) {
      this.trigger("beforeShowColumn", this, key);
      return jQuery(".ex-dt-col-" + key).show();
    };

    /*
     * Hides the column.
     * @param {String} key - the key of the column
    */


    DataTable.prototype.hideColumn = function(key) {
      this.trigger("beforeHideColumn", this, key);
      return jQuery(".ex-dt-col-" + key).hide();
    };

    /*
     * Sorts given column.
     * @param {Object} column
     * @param {String} dir - ASC or DESC
    */


    DataTable.prototype.sortColumn = function(column, dir) {
      var jQuerycontainer, jQuerythEl;
      this.trigger("beforeSortColumn", this, column, dir);
      this.set("sortedBy", {
        key: column.key,
        dir: dir
      });
      jQuerycontainer = jQuery(this.container);
      jQuerythEl = jQuery(column.thEl);
      jQuerythEl.addClass("ex-dt-" + (dir.toLowerCase())).siblings().removeClass("ex-dt-asc ex-dt-desc");
      return this.refresh();
    };

    /*
     * Init events
    */


    DataTable.prototype.initEvents = function() {
      var filter, paginator, _i, _len, _ref1;
      if (paginator = this.get("paginator")) {
        paginator.on("currentPageChange", this.refresh);
        paginator.on("rowsPerPageChange", this.refresh);
      }
      if (paginator) {
        this.getStore().on("onDataChange", function(data) {
          if (data != null ? data.totalRecords : void 0) {
            return paginator.setTotalRecords(data.totalRecords);
          } else {
            return paginator.setTotalRecords(data.length);
          }
        });
      }
      _ref1 = this.get("filters");
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        filter = _ref1[_i];
        filter.on("valueChange", this.refresh);
      }
      jQuery(this.container).on("click", "thead th", this.onThClick);
      jQuery(this.container).on("click", "tbody tr", this.onRowClick);
      return jQuery(this.container).on("click", "tbody td", this.onCellClick);
    };

    /*
     * Find column by attribute name and its value
     * @param {String} attrName - attribute by which you want to search сolumn
     * @param {String} attrValue - value of attribute
     * @return {Object|null}
    */


    DataTable.prototype.getColumn = function(attrName, attrValue) {
      var column, columns, _i, _len;
      columns = this.get("columns");
      for (_i = 0, _len = columns.length; _i < _len; _i++) {
        column = columns[_i];
        if (column[attrName] === attrValue) {
          return column;
        }
      }
      return null;
    };

    /*
     * Get store instance
     * @return {Ex.Store}
    */


    DataTable.prototype.getStore = function() {
      return this.get("store");
    };

    /*
     * Render the TH elements
    */


    DataTable.prototype.renderColumns = function() {
      var classes, column, columns, divEl, i, sortedBy, thEl, theadRowEl, _i, _len;
      this.trigger("beforeRenderColumns", this);
      this.theadEl.innerHTML = '';
      theadRowEl = this.theadEl.insertRow(0);
      columns = this.get("columns");
      sortedBy = this.cfg.sortedBy;
      for (i = _i = 0, _len = columns.length; _i < _len; i = ++_i) {
        column = columns[i];
        thEl = theadRowEl.appendChild(document.createElement("th"));
        thEl.exData = {
          columnIndex: i
        };
        if (column.width) {
          thEl.width = column.width;
        }
        classes = ["ex-dt-col-" + column.key];
        if (column.sortable == null) {
          column.sortable = true;
        }
        if (column.sortable) {
          classes.push("ex-dt-sortable");
          if (!sortedBy.key) {
            sortedBy.key = column.key;
          }
        }
        if (column.hidden) {
          classes.push("ex-dt-hidden");
          thEl.style.display = "none";
        }
        classes.push("ex-dt-col-" + column.key);
        thEl.className = classes.join(" ");
        divEl = document.createElement("div");
        divEl.className = "ex-dt-cell-inner";
        divEl.appendChild(document.createTextNode(column.label));
        thEl.appendChild(divEl);
        column.thEl = thEl;
        theadRowEl.appendChild(thEl);
      }
      return this.theadEl.appendChild(theadRowEl);
    };

    /*
     * Renders the view with existing records
    */


    DataTable.prototype.render = function() {
      var TBody, THead, sortedBy;
      this.trigger("beforeTElements", this);
      THead = document.createElement("thead");
      TBody = document.createElement("tbody");
      this.theadEl = this.container.appendChild(THead);
      this.tbodyEl = this.container.appendChild(TBody);
      this.renderColumns();
      sortedBy = this.get("sortedBy");
      if (sortedBy.key) {
        return this.sortColumn(this.getColumn("key", sortedBy.key), sortedBy.dir);
      } else {
        return this.refresh();
      }
    };

    /*
     * Re-render records in the datatable
    */


    DataTable.prototype.refresh = function() {
      var sortedBy,
        _this = this;
      this.trigger("beforeRefresh", this);
      sortedBy = this.cfg.sortedBy;
      return this.getStore().compute(sortedBy.key, sortedBy.dir, function(storeData) {
        var column, columns, divEl, filter, filters, from, i, j, key, paginator, record, rowFormatter, tdEl, text, to, trEl, _i, _j, _k, _len, _len1, _len2;
        columns = _this.get("columns");
        rowFormatter = _this.get("rowFormatter");
        paginator = _this.get("paginator");
        filters = _this.get("filters");
        for (_i = 0, _len = filters.length; _i < _len; _i++) {
          filter = filters[_i];
          if (filter.isSelected()) {
            storeData = storeData.filter(function(element, index, array) {
              return filter.filter(element, index, array);
            });
          }
        }
        if (paginator) {
          from = (paginator.getCurrentPage() - 1) * paginator.getRowsPerPage();
          to = paginator.getCurrentPage() * paginator.getRowsPerPage();
        }
        storeData = _this._data = storeData.slice(from, to);
        _this.tbodyEl.innerHTML = '';
        for (i = _j = 0, _len1 = storeData.length; _j < _len1; i = ++_j) {
          record = storeData[i];
          trEl = _this.tbodyEl.insertRow(i);
          if (typeof rowFormatter === "function") {
            rowFormatter(trEl, record);
          }
          trEl.className = "ex-dt-" + (i % 2 ? 'odd' : 'even');
          trEl.dataIndex = i;
          for (j = _k = 0, _len2 = columns.length; _k < _len2; j = ++_k) {
            column = columns[j];
            tdEl = trEl.insertCell(j);
            tdEl.className = "ex-dt-col-" + column.key;
            if (typeof column.formatter === "function") {
              column.formatter(tdEl, column, record);
            } else {
              divEl = document.createElement("div");
              divEl.className = "ex-dt-cell-inner";
              key = column.key;
              if (record[key]) {
                if (typeof record[key] === "function") {
                  text = record[key]();
                } else {
                  text = record[key];
                }
              } else if (typeof record.get === "function") {
                text = record.get(key);
              }
              divEl.appendChild(document.createTextNode(text));
              tdEl.appendChild(divEl);
            }
            if (column.hidden) {
              tdEl.className += " hidden";
              tdEl.style.display = "none";
            }
          }
          _this.tbodyEl.appendChild(trEl);
        }
        return _this.trigger("afterRefresh", _this);
      });
    };

    /*
     * Invokes when a cell has a click.
     * @param {Object} event - the event object
    */


    DataTable.prototype.onCellClick = function(event) {
      var column, columns, data, store, tdEl;
      tdEl = event.currentTarget;
      columns = this.get("columns");
      store = this.get("store");
      data = this.getData(tdEl.parentNode.dataIndex);
      column = columns[tdEl.cellIndex];
      return this.trigger("onCellClick", event, column, store, data);
    };

    /*
     * Invokes when a row has a click.
     * @param {Object} event - the event object
    */


    DataTable.prototype.onRowClick = function(event) {
      var data, store, trEl;
      trEl = event.currentTarget;
      data = this._data[trEl.dataIndex];
      store = this.get("store");
      return this.trigger("onRowClick", event, store, data);
    };

    /*
     * Invokes when a col has a click.
     * @param {Object} event - the event object
    */


    DataTable.prototype.onThClick = function(event) {
      var column, columns, dir, store, thEl;
      thEl = event.currentTarget;
      columns = this.get("columns");
      column = columns[thEl.cellIndex];
      this.trigger("onThClick", {
        event: event,
        column: column,
        store: store = this.get("store")
      });
      if (column.sortable) {
        dir = this.get("sortedBy").dir === "ASC" ? "DESC" : "ASC";
        return this.sortColumn(column, dir);
      }
    };

    return DataTable;

  })();

  /*
   * Base class for filters.
  */


  Ex.Filter = (function() {

    $.extend(Filter.prototype, Ex.AttributeProvider.prototype);

    function Filter(config) {}

    Filter.prototype.filter = function(element, index, array) {};

    Filter.prototype.isSelected = function() {};

    return Filter;

  })();

  /*
   * Search fiter.
  */


  Ex.Filter.Search = (function(_super) {

    __extends(Search, _super);

    function Search(config) {
      var defaults,
        _this = this;
      this._applyFilters = function(element, index, array) {
        return Search.prototype._applyFilters.apply(_this, arguments);
      };
      Search.__super__.constructor.apply(this, arguments);
      defaults = {
        container: null,
        filterFn: this._applyFilters,
        valueUpdate: 'keydown',
        value: ''
      };
      this.cfg = $.extend(defaults, config);
      this.cfg.container = jQuery(this.cfg.container);
      this.initEvents();
    }

    /*
     *
    */


    Search.prototype.initEvents = function() {
      var event,
        _this = this;
      event = this.get("valueUpdate");
      return this.get("container").on(event, Ex.util.throttle(function(event) {
        return _this.set("value", jQuery(event.target).val());
      }, 100));
    };

    /*
     * Filter the data
    */


    Search.prototype.filter = function(element, index, array) {
      var _base;
      return typeof (_base = this.get("filterFn")) === "function" ? _base(element, index, array) : void 0;
    };

    /*
     * Check that the filter has been selected
     * @return {Bool}
    */


    Search.prototype.isSelected = function() {
      return !!this.get("value");
    };

    /*
     * Method to filter the data
    */


    Search.prototype._applyFilters = function(element, index, array) {
      var name, predicate, record, value;
      value = this.get("value").toLowerCase();
      predicate = false;
      for (name in element) {
        record = element[name];
        if (~((record + "").toLowerCase().indexOf(value))) {
          predicate = true;
          break;
        }
      }
      return predicate;
    };

    return Search;

  })(Ex.Filter);

  /*
   * The Paginator Control allows you to reduce the page size and render time of your site 
   * or web application by breaking up large data sets into discrete pages. 
   * Parameters:
   *    config <Object> Object literal to set instance and ui component configuration.
  */


  Ex.Paginator = (function() {

    jQuery.extend(Paginator.prototype, Ex.AttributeProvider.prototype);

    function Paginator(config) {
      var defaults,
        _this = this;
      this.config = config;
      this._handlePageChange = function(event) {
        return Paginator.prototype._handlePageChange.apply(_this, arguments);
      };
      this._handleStateChange = function() {
        return Paginator.prototype._handleStateChange.apply(_this, arguments);
      };
      this.render = function() {
        return Paginator.prototype.render.apply(_this, arguments);
      };
      this.updateVisibility = function() {
        return Paginator.prototype.updateVisibility.apply(_this, arguments);
      };
      defaults = {
        rowsPerPage: 30,
        rowsPerPageSelect: null,
        container: '',
        totalRecords: 0,
        currentPage: 1,
        alwaysVisible: false
      };
      this.cfg = jQuery.extend(defaults, config);
      this.cfg.container = jQuery(this.cfg.container).eq(0);
      this._initUIComponents();
      this._initEvents();
      this._selfSubscribe();
      this.render();
    }

    /* 
     * Hides the containers if there is only one page of data and attribute alwaysVisible is false.
    */


    Paginator.prototype.updateVisibility = function() {
      var container, next, prev;
      container = this.get("container");
      prev = container.find(".ex-pg-first, .ex-pg-prev");
      next = container.find(".ex-pg-last, .ex-pg-next");
      if ((prev.hasClass("disabled") && this.hasPrevPage()) || !this.hasPrevPage()) {
        prev.toggleClass("disabled");
      }
      if ((next.hasClass("disabled") && this.hasNextPage()) || !this.hasNextPage()) {
        return next.toggleClass("disabled");
      }
    };

    /*
     * Render the pagination controls per the format attribute into the specified container nodes.
    */


    Paginator.prototype.render = function() {
      var container, currentPage, from, i, liEl, linkEl, nextEl, to, totalPages, totalRecords, ulEl, _results;
      totalRecords = this.getTotalRecords();
      container = this.get("container");
      currentPage = this.getCurrentPage();
      container.find(".ex-pg-page").remove();
      nextEl = container.find(".ex-pg-next").get(0);
      ulEl = container.find(">ul").get(0);
      totalPages = this.getTotalPages();
      to = currentPage + 4;
      from = currentPage - 4;
      if (from <= 0) {
        to += Math.abs(from) + 1;
        from = 1;
      }
      if (to > totalPages) {
        from -= to - totalPages;
        to = totalPages;
      }
      if (from <= 0) {
        from = 1;
      }
      if (to > totalPages) {
        to = totalPages;
      }
      i = from;
      _results = [];
      while (i <= to) {
        liEl = document.createElement("li");
        liEl.className = "ex-pg-page";
        linkEl = document.createElement("a");
        linkEl.href = "#";
        linkEl.textContent = i;
        if (i === currentPage) {
          liEl.className += " active";
        }
        liEl.setAttribute("data-page", i);
        liEl.appendChild(linkEl);
        ulEl.insertBefore(liEl, nextEl);
        _results.push(i++);
      }
      return _results;
    };

    /*
     * Get the total number of records.
     * @return {Number}
    */


    Paginator.prototype.getTotalRecords = function() {
      return +this.get("totalRecords");
    };

    /*
     * Set the total number of records.
    */


    Paginator.prototype.setTotalRecords = function(total) {
      if (this.getTotalRecords() !== total) {
        return this.set("totalRecords", total);
      }
    };

    /*
     * Get the number of rows per page.
     * @return {Number}
    */


    Paginator.prototype.getRowsPerPage = function() {
      return this.get("rowsPerPage");
    };

    /*
     * Set the number of rows per page.
    */


    Paginator.prototype.setRowsPerPage = function(number) {
      return this.set("rowsPerPage", number);
    };

    /*
     * Get the page number corresponding to the current record offset.
    */


    Paginator.prototype.getCurrentPage = function() {
      return this.get("currentPage");
    };

    /*
     * Set the current page to the provided page number if possible.
     * Parameters:
     *  newPage <number> the new page number
    */


    Paginator.prototype.setPage = function(newPage) {
      if (this.hasPage(newPage)) {
        return this.set("currentPage", newPage);
      }
    };

    /*
     * Get the total number of pages in the data set according to the current rowsPerPage and totalRecords values.
     * @return {Number}
    */


    Paginator.prototype.getTotalPages = function() {
      var totalPages;
      totalPages = this.getTotalRecords() / this.getRowsPerPage();
      if (totalPages > Math.floor(totalPages)) {
        totalPages++;
      }
      return Math.floor(totalPages);
    };

    /*
     * Does the requested page have any records?
     * @return {Bool}
    */


    Paginator.prototype.hasPage = function(page) {
      if (page < 1) {
        return false;
      }
      return page <= this.getTotalPages();
    };

    /*
     * Are there records on the next page?
    * @return {Bool}
    */


    Paginator.prototype.hasNextPage = function() {
      return this.hasPage(this.getCurrentPage() + 1);
    };

    /*
     * Is there a page before the current page?
    */


    Paginator.prototype.hasPrevPage = function() {
      return this.hasPage(this.getCurrentPage() - 1);
    };

    /*
     *  Fires the pageChange event when the state attributes have changed
    */


    Paginator.prototype._handleStateChange = function() {
      var totalPages;
      totalPages = this.getTotalPages();
      if (totalPages <= 1) {
        if (!this.get("alwaysVisible")) {
          this.get("container").hide("fast");
        }
      } else if (!this.get("alwaysVisible")) {
        this.get("container").show("fast");
      }
      if (this.getCurrentPage() > totalPages) {
        this.setPage(totalPages);
      }
      this.render();
      return this.updateVisibility();
    };

    /*
     *  Fires the pageChange event when the state attributes have changed
    */


    Paginator.prototype._handlePageChange = function(event) {
      var currentPage, page, target, totalPages;
      target = jQuery(event.currentTarget);
      currentPage = this.getCurrentPage();
      totalPages = this.getTotalPages();
      page = target.data("page");
      if (page === "prev") {
        page = currentPage - 1;
      } else if (page === "next") {
        page = currentPage + 1;
      } else if (page === "last") {
        page = totalPages;
      }
      if (page !== currentPage) {
        return this.setPage(+page);
      }
    };

    Paginator.prototype._initEvents = function() {
      var select,
        _this = this;
      this.get("container").on("click", "li", this._handlePageChange);
      if (select = this.get("rowsPerPageSelect")) {
        select = jQuery(select);
        return select.on("change", function(event) {
          return _this.set("rowsPerPage", select.val());
        });
      }
    };

    /*
     * Subscribes to instance attribute change events to automate certain behaviors.
    */


    Paginator.prototype._selfSubscribe = function() {
      this.on("rowsPerPageChange", this._handleStateChange);
      this.on("totalRecordsChange", this._handleStateChange);
      this.on("currentPageChange", this.render);
      return this.on("currentPageChange", this.updateVisibility);
    };

    /*
     * Renders the paginator UI
    */


    Paginator.prototype._initUIComponents = function() {
      var ulEl;
      ulEl = jQuery("<ul />", {
        "class": "ex-pg"
      });
      ulEl.append(jQuery("<li />", {
        "class": "ex-pg-first"
      }).append(jQuery("<a />", {
        href: "#",
        text: "First"
      })).data("page", 1), jQuery("<li />", {
        "class": "ex-pg-prev"
      }).append(jQuery("<a />", {
        href: "#",
        text: "Prev"
      })).data("page", "prev"), jQuery("<li />", {
        "class": "ex-pg-next"
      }).append(jQuery("<a />", {
        href: "#",
        text: "Next"
      })).data("page", "next"), jQuery("<li />", {
        "class": "ex-pg-last"
      }).append(jQuery("<a />", {
        href: "#",
        text: "Last"
      })).data("page", "last"));
      return this.get("container").css({
        display: "none"
      }).empty().append(ulEl);
    };

    return Paginator;

  })();

  /*
   * The Store class encapsulates a client side cache of Model objects
   * The constructor accepts the following parameters:
   *  - configs {Object} (optional) Object literal of configuration values.
  */


  Ex.Store = (function() {

    $.extend(Store.prototype, Ex.AttributeProvider.prototype);

    Store.prototype._data = [];

    /*
     * @constructor
    */


    function Store(configs) {
      if (configs == null) {
        configs = {};
      }
      this.cfg = configs;
    }

    /*
     * Set the data
     * @param {Object} data
    */


    Store.prototype.setData = function(data) {
      this._data = jQuery.extend([], data);
      return this.trigger("onDataChange", this._data);
    };

    /*
     * Get the data
     * @return {Object}
    */


    Store.prototype.getData = function() {
      return this._data;
    };

    /*
     * Compute data taking into account order
     * @return {Object}
    */


    Store.prototype.compute = function(key, dir, callback) {
      return typeof callback === "function" ? callback(this._data) : void 0;
    };

    /*
     * Remove record from store
     * @param {Number, Function}
    */


    Store.prototype.remove = function(item) {
      var i, record, result, _i, _len, _ref1, _results;
      switch (typeof item) {
        case "number":
          return this._data.splice(item, 1);
        case "function":
          _ref1 = this.data;
          _results = [];
          for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
            record = _ref1[i];
            result = item(record, i);
            if (result === true) {
              _results.push(this._data.splice(index, 1));
            } else if (result === false) {
              break;
            } else {
              _results.push(void 0);
            }
          }
          return _results;
      }
    };

    return Store;

  })();

  /*
   * Small helper class to make creating stores from Array data easier
   * @namespace Ex
   * @class ArrayStore
   * @extends Ex.Store
  */


  Ex.ArrayStore = (function(_super) {

    __extends(ArrayStore, _super);

    ArrayStore.prototype.paginator = null;

    function ArrayStore(configs) {
      ArrayStore.__super__.constructor.call(this, configs);
      if (configs.data) {
        this.setData(configs.data);
      }
    }

    /*
     * Compute data taking into account order
     * @return {Object}
    */


    ArrayStore.prototype.compute = function(key, dir, callback) {
      var data;
      data = this.getData();
      data.sort(function(a, b) {
        var asc, val1, val2;
        asc = dir === "ASC";
        val1 = a[key];
        val2 = b[key];
        if (val1 < val2) {
          if (asc) {
            return -1;
          } else {
            return 1;
          }
        }
        if (val1 === val2) {
          return 0;
        } else {
          if (asc) {
            return 1;
          } else {
            return -1;
          }
        }
      });
      return typeof callback === "function" ? callback(data) : void 0;
    };

    return ArrayStore;

  })(Ex.Store);

  /*
   * Small helper class to make creating stores from HTML table easier
   * @namespace Ex
   * @class TableStore
   * @extends Ex.ArrayStore
  */


  Ex.TableStore = (function(_super) {

    __extends(TableStore, _super);

    /*
     * @constructor
     * @param {Object} config  Contains: 
     * - container
     * - field - An array with fields names
    */


    function TableStore(configs) {
      var data, fields;
      fields = configs.fields;
      data = [];
      jQuery("tbody tr", configs.container).each(function(key, rowEl) {
        var cells, field, i, obj, _i, _len;
        cells = $(rowEl).find(">td");
        obj = {};
        for (i = _i = 0, _len = fields.length; _i < _len; i = ++_i) {
          field = fields[i];
          obj[field] = cells.eq(i).text();
        }
        return data.push(obj);
      });
      configs.data = data;
      TableStore.__super__.constructor.call(this, configs);
    }

    return TableStore;

  })(Ex.ArrayStore);

  /*
   * Remove store
  */


  Ex.RemoteStore = (function(_super) {

    __extends(RemoteStore, _super);

    RemoteStore.prototype.paginator = null;

    /*
     * @constructor
     * @param {Object} configs  Contains: 
     *   - url
    */


    function RemoteStore(configs) {
      RemoteStore.__super__.constructor.call(this, configs);
      this.paginator = configs != null ? configs.paginator : void 0;
      if (!configs.url) {
        console.warning("You should specity the url");
      }
    }

    /*
     * Compute data taking into account order
     * @return {Object}
    */


    RemoteStore.prototype.compute = function(key, dir, callback) {
      var data,
        _this = this;
      data = {};
      data.key = key;
      data.dir = dir;
      return $.ajax({
        url: this.get("url"),
        type: "POST",
        data: data,
        dataType: "json",
        success: function(response, textStatus, jqXHR) {
          _this.setData(response);
          return typeof callback === "function" ? callback(response.records) : void 0;
        }
      });
    };

    return RemoteStore;

  })(Ex.Store);

  /*
   * Utility Components
  */


  if ((_ref1 = Ex.util) == null) {
    Ex.util = {};
  }

  /*
   * Throttling function calls
  */


  Ex.util.throttle = function(fn, delay) {
    var timer;
    timer = null;
    return function() {
      var args, context;
      context = this;
      args = arguments;
      clearTimeout(timer);
      return timer = setTimeout(function() {
        return fn.apply(context, args);
      }, delay);
    };
  };

}).call(this);
