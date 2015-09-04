defmodule BenchmarkIps.Mixfile do
  use Mix.Project

  def project do
    [
      app: :benchmark_ips,
      version: "0.1.0",
      elixir: "~> 1.0",
      description: description,
      package: package,
      deps: deps
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
    []
  end
end
