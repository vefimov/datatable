example = {}

$ ->
  columns = [
    key: "id"
    label: "#"
    sortable: false
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

  store = new Ex.ArrayStore
    data: [
      "id" : "1"
      "first_name": "Mark",
      "last_name": "Otto"
    ,
      "id" : "2"
      "first_name": "Jacob",
      "last_name": "Thornton"
    ]

  example.datatable = new Ex.DataTable "table",
    columns: columns
    fields: fields
    store: store