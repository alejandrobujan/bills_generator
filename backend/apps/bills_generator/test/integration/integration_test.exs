defmodule IntegrationTest do
  alias BillsGenerator.Application
  alias BillsGenerator.Repository.{Repo, BillDao}
  use BillsGenerator.DataCase

  @valid_bill_request """
  {
    "user": "A user",
    "bill": {
      "title": "A title",
      "purchaser": "A purchaser",
      "seller": "A seller",
      "products": [
        {
          "name": "A product",
          "price": 1.5,
          "quantity": 30
        },
        {
          "name": "Another product",
          "price": 15,
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

  # setup do
  #   Application.start(:bills_generator)
  #   :ok
  # end

  test "generate_bill/1 from valid bill request generates bill successfully" do
    bill_id = Application.generate_bill(@valid_bill_request)
    # sleep for 0.5s in order to ensure bill is generated
    Process.sleep(500)
    bill = Repo.get!(BillDao, bill_id)
    assert bill.user == "A user"
    assert bill.title == "A title"
    assert bill.pdf != nil
    assert bill.error == false
    assert bill.error_msg == nil
  end

  test "generate_bill/1 from syntax error json generates bill with error message" do
    bill_id = Application.generate_bill("invalid json")
    # sleep for 0.5s in order to ensure bill is generated
    Process.sleep(500)
    bill = Repo.get!(BillDao, bill_id)
    assert bill.user == nil
    assert bill.title == nil
    assert bill.pdf == nil
    assert bill.error == true
    assert bill.error_msg == "unexpected token at position 0: i"
  end

  test "generate_bill/1 from incorrect config generates bill with error message" do
    json_bill = """
    {
      "user": "A user",
      "bill": {
        "title": "A title",
        "purchaser": "A purchaser",
        "seller": "A seller",
        "products": [
          {
            "name": "A product",
            "price": 1.5,
            "quantity": 30
          },
          {
            "name": "Another product",
            "price": 15,
            "quantity": 2
          }
        ]
      },
      "config": {
        "font_size" : 10,
        "font_style" : "not a font style",
        "paper_size" : "b5paper",
        "landscape" : true
      }
    }
    """

    bill_id = Application.generate_bill(json_bill)
    # sleep for 0.5s in order to ensure bill is generated
    Process.sleep(500)
    bill = Repo.get!(BillDao, bill_id)
    assert bill.user == nil
    assert bill.title == nil
    assert bill.pdf == nil
    assert bill.error == true

    assert bill.error_msg ==
             "Font style 'not a font style' not supported. Available font styles are: latex, times."
  end
end