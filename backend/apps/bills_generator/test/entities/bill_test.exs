defmodule BillsGenerator.Test.BillTest do
  alias BillsGenerator.Entities.{Bill, Product}
  use ExUnit.Case
  doctest Bill

  @title "A bill"
  @purchaser "A purchaser"
  @seller "A seller"
  @date "2021-07-10"
  @products [
    Product.new("A product", 15.0, 2, 10.0),
    Product.new("Another product", 3.0, 3)
  ]
  @taxes 20.0

  test "new/6 returns a new Bill struct" do
    bill = Bill.new(@title, @purchaser, @seller, @date, @products, @taxes)
    assert bill.title == @title
    assert bill.purchaser == @purchaser
    assert bill.seller == @seller
    assert bill.date == @date
    assert bill.products == @products
    assert bill.taxes == @taxes
    assert bill.total_bf_taxes == nil
    assert bill.taxes_amount == nil
    assert bill.total == nil
  end

  test "update_total/1 updates the total field" do
    bill = Bill.new(@title, @purchaser, @seller, @date, @products, @taxes)
    [product1, product2] = bill.products
    assert bill.total == nil
    assert product1.total == nil
    assert product2.total == nil

    bill = Bill.update_total(bill)
    [product1, product2] = bill.products
    assert bill.total == 43.2
    assert product1.total == 27.0
    assert product2.total == 9.0
  end

  test "update_total/1 updates the total field with empty products" do
    bill = Bill.new(@title, @purchaser, @seller, @date, [], @taxes)
    assert bill.total == nil
    assert bill.products == []

    bill = Bill.update_total(bill)
    assert bill.total == 0.0
    assert bill.products == []
  end

  test "update_total/1 updates the total field with nil products" do
    bill = Bill.new(@title, @purchaser, @seller, @date, nil, @taxes)
    assert bill.total == nil
    assert bill.products == []

    bill = Bill.update_total(bill)
    assert bill.total == 0.0
    assert bill.products == []
  end

  # Validate bill
  test "validate/1 returns {:ok, bill} when bill is valid" do
    bill = Bill.new(@title, @purchaser, @seller, @date, @products, @taxes)
    assert Bill.validate(bill) == :ok
  end

  test "validate/1 returns error when title is empty" do
    bill = Bill.new("", @purchaser, @seller, @date, @products, @taxes)
    assert Bill.validate(bill) == {:error, "Title can't be empty."}
  end

  test "validate/1 returns error when title is not a string" do
    bill = Bill.new(123, @purchaser, @seller, @date, @products, @taxes)
    assert Bill.validate(bill) == {:error, "Incorrect title value '123'. Title must be a string."}
  end

  test "validate/1 returns error when purchaser is empty" do
    bill = Bill.new(@title, "", @seller, @date, @products, @taxes)
    assert Bill.validate(bill) == {:error, "Purchaser can't be empty."}
  end

  test "validate/1 returns error when purchaser is not a string" do
    bill = Bill.new(@title, 123, @seller, @date, @products, @taxes)

    assert Bill.validate(bill) ==
             {:error, "Incorrect purchaser value '123'. Purchaser must be a string."}
  end

  test "validate/1 returns error when seller is empty" do
    bill = Bill.new(@title, @purchaser, "", @date, @products, @taxes)
    assert Bill.validate(bill) == {:error, "Seller can't be empty."}
  end

  test "validate/1 returns error when seller is not a string" do
    bill = Bill.new(@title, @purchaser, 123, @date, @products, @taxes)

    assert Bill.validate(bill) ==
             {:error, "Incorrect seller value '123'. Seller must be a string."}
  end

  test "validate/1 returns error when date is not valid" do
    bill = Bill.new(@title, @purchaser, @seller, "2015-01-32", @products, @taxes)
    assert Bill.validate(bill) == {:error, "Date must be a valid date."}
  end

  test "validate/1 returns error when date is not well-formatted" do
    bill = Bill.new(@title, @purchaser, @seller, "2015:01:23", @products, @taxes)
    assert Bill.validate(bill) == {:error, "Date must be formatted as iso8601 (yyyy-MM-dd)."}
  end

  test "validate/1 returns error when products list is nil" do
    bill = Bill.new(@title, @purchaser, @seller, @date, nil, @taxes)
    assert Bill.validate(bill) == {:error, "Products list can't be empty."}
  end

  test "validate/1 returns error when products list is empty" do
    bill = Bill.new(@title, @purchaser, @seller, @date, [], @taxes)
    assert Bill.validate(bill) == {:error, "Products list can't be empty."}
  end

  test "validate/1 returns error when products is not a list of products" do
    bill = Bill.new(@title, @purchaser, @seller, @date, ["A product"], @taxes)
    assert Bill.validate(bill) == {:error, "Incorrect product value. Not a Product type."}
  end

  test "validate/1 returns error when products is a list of integers" do
    bill = Bill.new(@title, @purchaser, @seller, @date, [1, 2], @taxes)
    assert Bill.validate(bill) == {:error, "Incorrect product value. Not a Product type."}
  end

  test "validate/1 returns error when taxes value is not a number" do
    bill = Bill.new(@title, @purchaser, @seller, @date, @products, "14")
    assert Bill.validate(bill) == {:error, "Incorrect taxes value '14'. Bill taxes must be a number."}
  end

  test "validate/1 returns error when taxes value is lesser than 0" do
    bill = Bill.new(@title, @purchaser, @seller, @date, @products, -5.0)
    assert Bill.validate(bill) == {:error, "Bill taxes must be greater or equal than 0."}
  end
end
