defmodule BillTest do
  alias BillsGenerator.Entities.{Bill, Product}
  use ExUnit.Case
  doctest Bill

  @title "A bill"
  @purchaser "A purchaser"
  @seller "A seller"
  @products [
    Product.new("A product", 15.0, 2),
    Product.new("Another product", 3.0, 3)
  ]

  test "new/4 returns a new Bill struct" do
    bill = Bill.new(@title, @purchaser, @seller, @products)
    assert bill.title == @title
    assert bill.purchaser == @purchaser
    assert bill.seller == @seller
    assert bill.products == @products
    assert bill.total == nil
  end

  test "update_total/1 updates the total field" do
    bill = Bill.new(@title, @purchaser, @seller, @products)
    [product1, product2] = bill.products
    assert bill.total == nil
    assert product1.total == nil
    assert product2.total == nil

    bill = Bill.update_total(bill)
    [product1, product2] = bill.products
    assert bill.total == 39.0
    assert product1.total == 30.0
    assert product2.total == 9.0
  end

  test "update_total/1 updates the total field with empty products" do
    bill = Bill.new(@title, @purchaser, @seller, [])
    assert bill.total == nil
    assert bill.products == []

    bill = Bill.update_total(bill)
    assert bill.total == 0.0
    assert bill.products == []
  end

  test "update_total/1 updates the total field with nil products" do
    bill = Bill.new(@title, @purchaser, @seller, nil)
    assert bill.total == nil
    assert bill.products == []

    bill = Bill.update_total(bill)
    assert bill.total == 0.0
    assert bill.products == []
  end

  # Validate bill
  test "validate/1 returns {:ok, bill} when bill is valid" do
    bill = Bill.new(@title, @purchaser, @seller, @products)
    assert Bill.validate(bill) == :ok
  end

  test "validate/1 returns error when title is empty" do
    bill = Bill.new("", @purchaser, @seller, @products)
    assert Bill.validate(bill) == {:error, "Title can't be empty."}
  end

  test "validate/1 returns error when title is not a string" do
    bill = Bill.new(123, @purchaser, @seller, @products)
    assert Bill.validate(bill) == {:error, "Incorrect title value '123'. Title must be a string."}
  end

  test "validate/1 returns error when purchaser is empty" do
    bill = Bill.new(@title, "", @seller, @products)
    assert Bill.validate(bill) == {:error, "Purchaser can't be empty."}
  end

  test "validate/1 returns error when purchaser is not a string" do
    bill = Bill.new(@title, 123, @seller, @products)

    assert Bill.validate(bill) ==
             {:error, "Incorrect purchaser value '123'. Purchaser must be a string."}
  end

  test "validate/1 returns error when seller is empty" do
    bill = Bill.new(@title, @purchaser, "", @products)
    assert Bill.validate(bill) == {:error, "Seller can't be empty."}
  end

  test "validate/1 returns error when seller is not a string" do
    bill = Bill.new(@title, @purchaser, 123, @products)

    assert Bill.validate(bill) ==
             {:error, "Incorrect seller value '123'. Seller must be a string."}
  end

  test "validate/1 returns error when products list is nil" do
    bill = Bill.new(@title, @purchaser, @seller, nil)
    assert Bill.validate(bill) == {:error, "Products list can't be empty."}
  end

  test "validate/1 returns error when products list is empty" do
    bill = Bill.new(@title, @purchaser, @seller, [])
    assert Bill.validate(bill) == {:error, "Products list can't be empty."}
  end

  test "validate/1 returns error when products is not a list of products" do
    bill = Bill.new(@title, @purchaser, @seller, ["A product"])
    assert Bill.validate(bill) == {:error, "Incorrect product value. Not a Product type."}
  end

  test "validate/1 returns error when products is a list of integers" do
    bill = Bill.new(@title, @purchaser, @seller, [1, 2])
    assert Bill.validate(bill) == {:error, "Incorrect product value. Not a Product type."}
  end
end
