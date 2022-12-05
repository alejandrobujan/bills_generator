defmodule BillConfigTest do
  alias BillsGenerator.Entities.BillConfig
  use ExUnit.Case
  doctest BillConfig

  test "new/4 returns a new bill config" do
    config = BillConfig.new(11, "latex", "a4paper", true)
    assert config.font_size == 11
    assert config.font_style == "latex"
    assert config.paper_size == "a4paper"
    assert config.landscape == true
  end

  test "validate/1 returns ok when config is valid" do
    config = BillConfig.new(11, "latex", "a4paper", true)

    assert :ok = BillConfig.validate(config)
  end

  test "validate/1 returns error when font size is not supported" do
    config = BillConfig.new(0, "latex", "a4paper", true)

    assert {:error, "Font size '0' not supported. Available font sizes are: 10, 11, 12."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when font size is not a number" do
    config = BillConfig.new("11", "latex", "a4paper", true)

    assert {:error, "Incorrect font size value '11'. Font size must be a number."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when font style is not supported" do
    config = BillConfig.new(11, "not_a_style", "a4paper", true)

    assert {:error,
            "Font style 'not_a_style' not supported. Available font styles are: latex, times."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when font style is not a string" do
    config = BillConfig.new(11, 11, "a4paper", true)

    assert {:error, "Incorrect font style value '11'. Font Style must be a string."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when paper size is not supported" do
    config = BillConfig.new(11, "latex", "not_a_paper_size", true)

    assert {:error,
            "Paper size: 'not_a_paper_size' not supported. Available paper sizes are: a4paper, a5paper, b5paper, letterpaper, legalpaper, executivepaper."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when paper size is not a string" do
    config = BillConfig.new(11, "latex", 11, true)

    assert {:error, "Incorrect paper size value '11'. Paper size must be a string."} =
             BillConfig.validate(config)
  end

  test "validate/1 returns error when landscape is not a boolean" do
    config = BillConfig.new(11, "latex", "a4paper", 5)

    assert {:error, "Incorrect landscape value '5'. Landscape must be a boolean."} =
             BillConfig.validate(config)
  end
end
