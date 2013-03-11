// Generated by CoffeeScript 1.6.1

/*
 * This work is licensed under the Creative Commons Attribution-NoDerivs 3.0 Unported License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-nd/3.0/ or send a
 * letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
*/


(function() {
  var _ref, _ref1,
    _this = this,
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

    jQuery.extend(AttributeProvider.prototype, EventEmitter.prototype);

    /*
     * Sets the value of a config.
    */


    AttributeProvider.prototype.set = function(name, value) {
      this.cfg[name] = value;
      return this.emit("" + name + "Change", value);
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
      var defaults, sortedBy,
        _this = this;
      this.render = function() {
        return DataTable.prototype.render.apply(_this, arguments);
      };
      this.onThClick = function(event) {
        return DataTable.prototype.onThClick.apply(_this, arguments);
      };
      this.onRowClick = function(event) {
        return DataTable.prototype.onRowClick.apply(_this, arguments);
      };
      this.onCellClick = function(event) {
        return DataTable.prototype.onCellClick.apply(_this, arguments);
      };
      defaults = {
        paginator: null,
        columns: [],
        store: null,
        filters: [],
        sortedBy: {
          key: null,
          dir: "ASC"
        }
      };
      this.container = jQuery(container).empty().get(0);
      this.cfg = $.extend(defaults, configs);
      this.theadEl = this.container.appendChild(this.container.createTHead());
      this.tbodyEl = this.container.appendChild(this.container.createTBody());
      this.renderColumns();
      sortedBy = this.get("sortedBy");
      if (sortedBy.key) {
        this.sortColumn(this.getColumn("key", sortedBy.key), sortedBy.dir);
      }
      this.render();
      this.initEvents();
    }

    DataTable.prototype.initEvents = function() {
      var filter, paginator, _i, _len, _ref1;
      if (paginator = this.get("paginator")) {
        paginator.on("currentPageChange", this.render);
        paginator.on("rowsPerPageChange", this.render);
      }
      this.getStore().on("onDataChange", function(data) {
        if (paginator) {
          return paginator.setTotalRecords(data.length);
        }
      });
      _ref1 = this.get("filters");
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        filter = _ref1[_i];
        filter.on("valueChange", this.render);
      }
      jQuery(this.container).on("click", "thead th", this.onThClick);
      jQuery(this.container).on("click", "tbody tr", this.onRowClick);
      return jQuery(this.container).on("click", "tbody td", this.onCellClick);
    };

    DataTable.prototype.onCellClick = function(event) {
      var tdEl;
      tdEl = event.currentTarget;
      return this.emit("onCellClick", {
        event: event,
        column: tdEl.exData.column,
        record: tdEl.exData.record
      });
    };

    DataTable.prototype.onRowClick = function(event) {
      var trEl;
      trEl = event.currentTarget;
      return this.emit("onRowClick", {
        event: event,
        column: trEl.exData.column,
        record: trEl.exData.record
      });
    };

    DataTable.prototype.onThClick = function(event) {
      var column, dir, thEl;
      thEl = event.currentTarget;
      column = thEl.exData.column;
      this.emit("onThClick", {
        event: event,
        column: column
      });
      if (column.sortable) {
        dir = this.get("sortedBy").dir === "ASC" ? "DESC" : "ASC";
        return this.sortColumn(column, dir);
      }
    };

    /*
     * Find column by attribute name and its value
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
    */


    DataTable.prototype.getStore = function() {
      return this.get("store");
    };

    /*getData: ->
      @_data
      
    setData: (data) ->
      @_data = data
    */


    /*
     * Render the TH elements
    */


    DataTable.prototype.renderColumns = function() {
      var classes, column, columns, divEl, thEl, theadRowEl, _i, _len;
      jQuery(this.theadEl).empty();
      theadRowEl = this.theadEl.insertRow(0);
      columns = this.get("columns");
      for (_i = 0, _len = columns.length; _i < _len; _i++) {
        column = columns[_i];
        thEl = theadRowEl.appendChild(document.createElement("th"));
        thEl.exData = {
          column: column
        };
        if (column.width) {
          thEl.width = column.width;
        }
        classes = ["ex-dt-col-" + column.key];
        if (column.sortable) {
          classes.push("ex-dt-sortable");
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
      var column, columns, divEl, filter, filters, from, i, j, paginator, record, rowFormatter, sortedBy, storeData, tdEl, to, trEl, _i, _j, _k, _len, _len1, _len2;
      console.time("Rendering data");
      storeData = this.getStore().getData();
      columns = this.get("columns");
      sortedBy = this.get("sortedBy");
      rowFormatter = this.get("rowFormatter");
      paginator = this.get("paginator");
      filters = this.get("filters");
      for (_i = 0, _len = filters.length; _i < _len; _i++) {
        filter = filters[_i];
        if (filter.isSelected()) {
          storeData = storeData.filter(function(element, index, array) {
            return filter.filter(element, index, array);
          });
        }
      }
      if (paginator) {
        paginator.setTotalRecords(storeData.length);
      }
      from = 0;
      to = 10;
      if (paginator) {
        from = (paginator.getCurrentPage() - 1) * paginator.getRowsPerPage();
        to = paginator.getCurrentPage() * paginator.getRowsPerPage();
      }
      storeData = storeData.slice(from, to);
      jQuery(this.tbodyEl).empty();
      for (i = _j = 0, _len1 = storeData.length; _j < _len1; i = ++_j) {
        record = storeData[i];
        trEl = this.tbodyEl.insertRow(i);
        trEl.exData = {
          record: record
        };
        if (typeof rowFormatter === "function") {
          rowFormatter(trEl, record);
        }
        trEl.className = "ex-dt-" + (i % 2 ? 'odd' : 'even');
        for (j = _k = 0, _len2 = columns.length; _k < _len2; j = ++_k) {
          column = columns[j];
          tdEl = trEl.insertCell(j);
          tdEl.exData = {
            columnIndex: j
          };
          /*tdEl.exData =
              column: column
              record: record
          */

          tdEl.className = "ex-dt-col-" + column.key;
          if (typeof column.formatter === "function") {
            column.formatter(tdEl, column, record);
          } else {
            divEl = document.createElement("div");
            divEl.className = "ex-dt-cell-inner";
            divEl.appendChild(document.createTextNode(record[column.key]));
            tdEl.appendChild(divEl);
          }
          if (column.hidden) {
            tdEl.className += " hidden";
            tdEl.style.display = "none";
          }
        }
        this.tbodyEl.appendChild(trEl);
      }
      /*for record in storeData
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
        @tbodyEl.append trEl
      */

      return console.timeEnd("Rendering data");
    };

    /*
     * Custom event handler to sort Column.
    */


    /*onEventSortColumn: (column) =>
      if column.sortable
        dir = if @get("sortedBy").dir is "ASC" then "DESC" else "ASC"
        # Update UI via sortedBy
        @sortColumn column, dir
    */


    /*
     * Sorts given Column.
    */


    DataTable.prototype.sortColumn = function(column, dir) {
      this.set("sortedBy", {
        key: column.key,
        dir: dir
      });
      $(column.thEl).addClass("ex-dt-" + (dir.toLowerCase())).parent().find(".ex-dt-asc, .ex-dt-desc").removeClass("ex-dt-asc ex-dt-desc");
      return this.getStore().sort(column.key, dir);
    };

    DataTable.prototype.showColumn = function(key) {
      return jQuery(".ex-dt-col-" + key).show();
    };

    DataTable.prototype.hideColumn = function(key) {
      return jQuery(".ex-dt-col-" + key).hide();
    };

    DataTable.prototype.removeColumn = function(key) {
      var column, columns, i, _i, _len, _results;
      columns = this.get("columns");
      _results = [];
      for (i = _i = 0, _len = columns.length; _i < _len; i = ++_i) {
        column = columns[i];
        if (column.key === key) {
          columns.splice(i, 1);
          _results.push(this.hideColumn(key));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    DataTable.prototype.addColumn = function(column, index) {
      var columns;
      if (index == null) {
        index = 0;
      }
      columns = this.get("columns");
      columns.splice(index, 0, column);
      this.renderColumns();
      return this.render();
    };

    return DataTable;

  })();

  /*getColumnByKey: (key) ->
      for column in @get("columns")
          if column.key is key
              return column
  */


  /*class Ex.DataTable.Column
      $.extend @prototype, Ex.AttributeProvider.prototype
      constructor: ->
  */


  /*
   * The Store class encapsulates a client side cache of Model objects
  */


  Ex.Store = (function() {

    $.extend(Store.prototype, Ex.AttributeProvider.prototype);

    Store.prototype._data = [];

    function Store(configs) {
      this.setData(configs.data);
      this.cfg = {};
    }

    Store.prototype.setData = function(data) {
      this._data = jQuery.extend([], data);
      return this.emit("onDataChange", this._data);
    };

    Store.prototype.getData = function(index) {
      if (typeof index !== "number") {
        return this._data;
      }
      return this._data[index];
    };

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
  */


  Ex.ArrayStore = (function(_super) {

    __extends(ArrayStore, _super);

    function ArrayStore(configs) {
      ArrayStore.__super__.constructor.apply(this, arguments);
    }

    ArrayStore.prototype.sort = function(key, dir) {
      this.getData().sort(function(a, b) {
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
      return this.emit("onDataChange", this.getData());
    };

    return ArrayStore;

  })(Ex.Store);

  /*
   *
  */


  Ex.TableStore = (function(_super) {

    __extends(TableStore, _super);

    function TableStore(configs) {
      var data, fields;
      fields = config.fields;
      data = [];
      jQuery("tbody tr", configs.container).each(function(key, rowEl) {
        var cells, field, obj, _i, _len, _results;
        cells = $(rowEl).find(">td");
        _results = [];
        for (_i = 0, _len = fields.length; _i < _len; _i++) {
          field = fields[_i];
          obj = {};
          obj[field] = cells.eq(_i).text();
          _results.push(data.push(obj));
        }
        return _results;
      });
      configs = {
        data: data
      };
      TableStore.__super__.constructor.call(this, config);
    }

    return TableStore;

  })(Ex.ArrayStore);

  Ex.RemoteStore = (function(_super) {

    __extends(RemoteStore, _super);

    function RemoteStore(configs) {
      RemoteStore.__super__.constructor.call(this, config);
    }

    return RemoteStore;

  })(Ex.ArrayStore);

  /*
   * Paginator 
   * Parameters:
   *    config <Object> Object literal to set instance and ui component configuration.
  */


  Ex.Paginator = (function() {

    $.extend(Paginator.prototype, Ex.AttributeProvider.prototype);

    function Paginator(config) {
      var defaults,
        _this = this;
      this.config = config;
      this._handlePageChange = function(event) {
        return Paginator.prototype._handlePageChange.apply(_this, arguments);
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
      config = $.extend(defaults, config);
      config.container = $(config.container).eq(0);
      this.cfg = config;
      this._initUIComponents();
      this.initEvents();
      this._selfSubscribe();
      this.setPage(1);
    }

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
        /*liEl = jQuery("<li />", class: "ex-pg-page").append(
          jQuery("<a />", href: "#", text: i)
        )
        
        liEl.addClass("active") if i is currentPage
        liEl.insertBefore(nextEl)
        liEl.data("page", i)
        */

        _results.push(i++);
      }
      return _results;
    };

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
    */


    Paginator.prototype.hasPage = function(page) {
      if (page < 1) {
        return false;
      }
      return page <= this.getTotalPages();
    };

    /*
     * Are there records on the next page?
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
      target = $(event.currentTarget);
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

    Paginator.prototype.initEvents = function() {
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
      return this.get("container").empty().append(ulEl);
    };

    return Paginator;

  })();

  Ex.Filter = (function() {

    $.extend(Filter.prototype, Ex.AttributeProvider.prototype);

    function Filter(config) {}

    Filter.prototype.filter = function(element, index, array) {};

    Filter.prototype.isSelected = function() {};

    return Filter;

  })();

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

    Search.prototype.initEvents = function() {
      var event,
        _this = this;
      event = this.get("valueUpdate");
      return this.get("container").on(event, Ex.util.throttle(function(event) {
        return _this.set("value", jQuery(event.target).val());
      }, 100));
    };

    Search.prototype.filter = function(element, index, array) {
      var _base;
      return typeof (_base = this.get("filterFn")) === "function" ? _base(element, index, array) : void 0;
    };

    Search.prototype.isSelected = function() {
      return !!this.get("value");
    };

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

  if ((_ref1 = Ex.util) == null) {
    Ex.util = {};
  }

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
