# define application namespace
window.Ex ?= {}

class Ex.Examples
	constructor: ->
		@initWidgets()

		i = 1
		while i < 3
			methodName = "initDt#{i}"
			@[methodName]()
			i++


	initWidgets: ->
		$(".nav-tabs a").click (e) ->
	    	e.preventDefault()
	    	$(this).tab "show"

	initDt1: ->
    	columnDefs = [
	        key: "id",
	        label: "ID"
	    ,
	        key: "name",
	        label: "Name"
	    ,
	        key: "phone",
	        label: "Phone"
	    ,
	        key: "city",
	        label: "City"
	    ,
	        key: "rating",
	        label: "Rating"
	    ]

	    store = new Ex.ArrayStore
	    	data: Ex.Examples.data

	    datatable = new Ex.DataTable "#p1-table", 
	    	columns : columnDefs
	    	store 	: store	

	initDt2: ->
    	columnDefs = [
	        key: "due",
	        label: "Due Date"
	    ,
	        key: "account",
	        label: "Account Number"
	    ,
	        key: "quantity",
	        label: "Quantity"
	    ,
	        key: "amount",
	        label: "Amount Due"
	    ]

	    store = new Ex.TableStore
	    	container: "#p2-table"
	    	fields: ["due", "account", "quantity", "amount"]

	    datatable = new Ex.DataTable "#p2-table", 
	    	columns : columnDefs
	    	store 	: store	


###
 * Data for samples
###
Ex.Examples.data = [
	id 		: 1
	name 	: "Giovanni's Pizzaria"
	phone	: "(408) 490-2658" 
	city	: "Sunnyvale"
	rating	: 4
,
	id 		: 2
	name 	: "Canton Chinese Fast Food"
	phone	: "(650) 961-1288" 
	city	: "Mountain View"
	rating	: 8
,
	id 		: 3
	name 	: "Chef Lee Chinese Restaurant"
	phone	: "(408) 734-3878" 
	city	: "Sunnyvale"
	rating	: 4
,
	id 		: 4
	name 	: "Chipotle Mexican Grill"
	phone	: "(408) 773-0247" 
	city	: "Sunnyvale"
	rating	: 3
,
	id 		: 5
	name 	: "El Cerrito"
	phone	: "(408) 745-7748" 
	city	: "San Jose"
	rating	: 'N/A'
,
	id 		: 6
	name 	: "Express 7 Chinese Fast Food"
	phone	: "(650) 960-7100" 
	city	: "Mountain View"
	rating	: 6
,
	id 		: 7
	name 	: "Hong Kong Saigon Seafood"
	phone	: "(408) 734-2828" 
	city	: "Sunnyvale"
	rating	: 3
]

jQuery ->
	Ex.examples = new Ex.Examples()

jQuery(window).load ->
	# make code pretty
    window.prettyPrint && prettyPrint()