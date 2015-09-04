defmodule BenchmarkIps.Mixfile do
  use Mix.Project

  def project do
    [
      app: :benchmark_ips,
      version: "0.2.0",
      elixir: "~> 1.0",
      description: description,
      package: package,
      deps: deps,
      docs: [main: "README", readme: "README.md"],
    ]
  end

  def application do
    []
  end

  def package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE", "examples"],
      contributors: ["Max Holder"],
      links: %{ "GitHub" => "https://github.com/mxhold/benchmark_ips" },
      licenses: ["MIT"],
    ]
  end

  def description do
    """
    A tool to run benchmarks to determine iteration per second.
    """
  end

  defp deps do
    [
      {:ex_doc, "~> 0.8", only: :dev},
      {:earmark, "~> 0.1", only: :dev},
    ]
  end
end
