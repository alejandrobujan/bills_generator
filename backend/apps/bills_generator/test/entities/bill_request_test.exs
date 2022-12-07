defmodule BillsGenerator.Test.BillRequestTest do
  alias BillsGenerator.Entities.{BillRequest, Product, Bill, BillConfig}
  use ExUnit.Case
  doctest BillRequest

  @user "John Doe"
  @title "A bill"
  @purchaser "A purchaser"
  @seller "A seller"
  @products [
    Product.new("A product", 15.0, 2),
    Product.new("Another product", 3.0, 3)
  ]
  @bill Bill.new(@title, @purchaser, @seller, @products)
  @bill_config BillConfig.new(11, "latex", "a4paper", true)

  test "new/4 returns a new BillRequest struct" do
    bill_request = BillRequest.new(@user, @bill, @bill_config)
    assert bill_request.user == @user
    assert bill_request.bill == @bill
    assert bill_request.config == @bill_config
  end

  # Validate bill request

  test "validate/1 returns ok when bill request is valid" do
    bill_request = BillRequest.new(@user, @bill, @bill_config)

    assert BillRequest.validate(bill_request) == :ok
  end

  test "validate/1 returns error when user is empty" do
    bill_request = BillRequest.new("", @bill, @bill_config)

    assert BillRequest.validate(bill_request) == {:error, "User can't be empty."}
  end

  test "validate/1 returns error when user is not a string" do
    bill_request = BillRequest.new(123, @bill, @bill_config)

    assert BillRequest.validate(bill_request) ==
             {:error, "Incorrect user value '123'. User must be a string."}
  end
end
