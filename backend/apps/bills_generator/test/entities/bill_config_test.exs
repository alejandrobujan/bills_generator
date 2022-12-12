defmodule BillsGenerator.Test.BillConfigTest do
  alias BillsGenerator.Entities.BillConfig
  use ExUnit.Case
  doctest BillConfig

  test "new/5 returns a new bill config" do
    config = BillConfig.new(11, "latex", "a4paper", true, "euro")
    assert config.font_size == 11
    assert config.font_style == "latex"
    assert config.paper_size == "a4paper"
    assert config.landscape == true
    assert config.currency == "euro"
  end

  test "validate/1 returns ok when config is valid" do
    config = BillConfig.new(11, "latex", "a4paper", true, "euro")

    assert :ok = BillConfig.validate(config)
  end

  test "validate/1 returns error when font size is not supported" do
    config = BillConfig.new(0, "latex", "a4paper", true, "euro")

    assert {:error, "Font size '0' not supported. Available font sizes are: 10, 11, 12."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when font size is not a number" do
    config = BillConfig.new("11", "latex", "a4paper", true, "euro")

    assert {:error, "Incorrect font size value '11'. Font size must be a number."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when font style is not supported" do
    config = BillConfig.new(11, "not_a_style", "a4paper", true, "euro")

    assert {:error,
            "Font style 'not_a_style' not supported. Available font styles are: latex, times."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when font style is not a string" do
    config = BillConfig.new(11, 11, "a4paper", true, "euro")

    assert {:error, "Incorrect font style value '11'. Font Style must be a string."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when paper size is not supported" do
    config = BillConfig.new(11, "latex", "not_a_paper_size", true, "euro")

    assert {:error,
            "Paper size 'not_a_paper_size' not supported. Available paper sizes are: a4paper, a5paper, b5paper, letterpaper, legalpaper, executivepaper."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when paper size is not a string" do
    config = BillConfig.new(11, "latex", 11, true, "euro")

    assert {:error, "Incorrect paper size value '11'. Paper size must be a string."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when landscape is not a boolean" do
    config = BillConfig.new(11, "latex", "a4paper", 5, "euro")

    assert {:error, "Incorrect landscape value '5'. Landscape must be a boolean."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when currency is not supported" do
    config = BillConfig.new(11, "latex", "a4paper", true, "not_a_currency")

    assert {:error,
            "Currency 'not_a_currency' not supported. Available currencies are: euro, dollar."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when currency is not a string" do
    config = BillConfig.new(11, "latex", "a4paper", true, 11)

    assert {:error, "Incorrect currency value '11'. Currency must be a string."} =
             BillConfig.validate(config)
  end
end
