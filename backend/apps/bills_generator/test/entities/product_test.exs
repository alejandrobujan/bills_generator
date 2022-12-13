defmodule BillsGenerator.Test.ProductTest do
  alias BillsGenerator.Entities.Product
  use ExUnit.Case
  doctest Product

  test "new/1 returns a new product" do
    product = Product.new("A product", 10.0, 2, 10.0)
    assert product.name == "A product"
    assert product.price == 10.0
    assert product.quantity == 2
    assert product.discount == 10.0
  end

  test "update_total/1 returns a product with total" do
    product = Product.new("A product", 10.0, 2, 10.0)
    updated_product = Product.update_total(product)
    assert updated_product.total == 18.0
  end

  test "validate/1 returns ok when product is valid" do
    product = Product.new("A product", 10.0, 2, 10.0)
    assert Product.validate(product) == :ok
  end

  test "validate/1 returns error when product is not a Product type" do
    product = "not a product"
    assert Product.validate(product) == {:error, "Incorrect product value. Not a Product type."}
  end

  test "validate/1 returns error when product name is empty" do
    product = Product.new("", 10.0, 2, 10.0)
    assert Product.validate(product) == {:error, "Product name can't be empty."}
  end

  test "validate/1 returns error when product name is not a string" do
    product = Product.new(1, 10.0, 2, 10.0)

    assert Product.validate(product) ==
             {:error, "Incorrect product name value '1'. Product name must be a string."}
  end

  test "validate/1 returns error when product price is lesser than 0" do
    product = Product.new("A product", -10.0, 2, 10.0)
    assert Product.validate(product) == {:error, "Product price must be greater or equal than 0."}
  end

  test "validate/1 returns error when product price is not a number" do
    product = Product.new("A product", "10.0", 2, 10.0)

    assert Product.validate(product) ==
             {:error, "Incorrect product price value '10.0'. Product price must be a number."}
  end

  test "validate/1 returns error when product quantity is lesser than 0" do
    product = Product.new("A product", 10.0, -2, 10.0)
    assert Product.validate(product) == {:error, "Product quantity must be greater than 0."}
  end

  test "validate/1 returns error when product quantity is not a number" do
    product = Product.new("A product", 10.0, "2", 10.0)

    assert Product.validate(product) ==
             {:error, "Incorrect product quantity value '2'. Product quantity must be a number."}
  end

  test "validate/1 returns error when product discount is lesser than 0" do
    product = Product.new("A product", 10.0, 2, -4.0)
    assert Product.validate(product) == {:error, "Product discount must be between 0 and 100."}
  end

  test "validate/1 returns error when product discount is greater than 100" do
    product = Product.new("A product", 10.0, 2, 104.0)
    assert Product.validate(product) == {:error, "Product discount must be between 0 and 100."}
  end

  test "validate/1 returns error when product discount is not a number" do
    product = Product.new("A product", 10.0, 2, "2.0")

    assert Product.validate(product) ==
             {:error, "Incorrect discount value '2.0'. Product discount must be a number."}
  end

end
