defmodule Flix.MixProject do
  use Mix.Project

  def project do
    [
      app: :flix,
      description: "An Elixir client for the Flic button.",
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # ExDoc
      name: "Flix",
      source_url: "https://github.com/efcasado/flix",
      homepage_url: "https://github.com/efcasado/flix",
      docs: [
        main: "Flix", # The main page in the docs
        extras: ["README.md"]
      ],

      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:enum_type, "~> 1.1"},
      {:ex_doc, "~> 0.25.1", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
     name: :flix,
     files: ["mix.exs", "lib", "test", "README*"],
     maintainers: ["Enrique Fernandez"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/efcasado/flix"}]
  end
end
