json_bill = """
{
	"user": "David",
	"bill": {
	  "title": "Titulo",
	  "purchaser": "Trile S.A",
	  "seller": "Corunat S.A",
	  "products": [
			{
				"name": "Coca Cola",
				"price": 1.5,
				"quantity": 2
			},
			{
				"name": "Pepsi",
				"price": 1,
				"quantity": 2
			}
	  ]
	},
	"config": {
		"font_size" : 10,
		"font_style" : "times",
		"paper_size" : "b5paper",
		"landscape" : true
	}
}
"""

bill_id = BillsGenerator.Application.generate_bill(json_bill)
