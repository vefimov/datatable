example = {}

$ ->
  columns = [
    key: "id"
    label: "#"
    sortable: true
    hidden: true
  ,
    key: "first_name"
    label: "First Name"
    formatter: null
    sortable: true
    hidden: false
  ,
    key: "last_name"
    label: "Last Name"
    formatter: null
    sortable: true
    hidden: false
  ]

  fields = ["id", "first_name", "last_name"]
  
  data = []
  
  i = 1
  while i < 200
    data.push
      "id" : i
      "first_name": "First Name #{i}",
      "last_name": "Last Name #{i}"      
    i++

  store = new Ex.ArrayStore
    data: data

  example.datatable = new Ex.DataTable "table",
    columns: columns
    fields: fields
    store: store
    sortedBy:
      key: "id"
      dir: "ASC"