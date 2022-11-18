defmodule BillGenerator.MixProject do
  use Mix.Project

  def project do
    [
      app: :bill_generator,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:iona],
      extra_applications: [:logger],
      mod: {BillGenerator.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:iona, "~> 0.4"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end
end
