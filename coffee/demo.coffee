example = {}

$ ->
  
  fistNameFormatter = (tdEl, column, data) ->
    unless data.id % 10
      $(tdEl).css("background", "rgb(199, 255, 199)")
    $(tdEl).text(data.first_name)
  
  
  rowFormatter = (trEl, data) ->
    $(trEl).addClass("error") unless data.id % 20
    
  
  columns = [
    key: "id"
    label: "#"
    sortable: false
    hidden: false
    width: 20
  ,
    key: "hidden"
    label: "Hidden"
    sortable: false
    hidden: true
  ,
    key: "first_name"
    label: "First Name"
    formatter: fistNameFormatter
    sortable: true
    hidden: false
  ,
    key: "last_name"
    label: "Last Name"
    formatter: null
    sortable: true
    hidden: false
  ]

  #fields = ["id", "first_name", "last_name"]
  
  data = []
  
  i = 1
  while i < 200
    data.push
      "id" : i
      "hidden" : i
      "first_name": "First Name #{i}",
      "last_name": "Last Name #{i}"      
    i++

  store = new Ex.ArrayStore
    data: data

  example.datatable = new Ex.DataTable "table",
    columns: columns
    #fields: fields
    store: store
    rowFormatter: rowFormatter
    paginator: new Ex.Paginator
      container: '.pagination'
      totalRecords: 200
      rowsPerPage: 10
      rowsPerPageSelect: "#rows-per-page"
    filters: [
      new Ex.Filter.Search container: "#search"
    ]
    sortedBy:
      key: "id"
      dir: "ASC"