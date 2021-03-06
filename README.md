# BenchmarkIps

[![Build Status](https://img.shields.io/travis/mxhold/benchmark_ips.svg?style=flat)](https://travis-ci.org/mxhold/benchmark_ips) [![Hex docs](http://img.shields.io/badge/hex.pm-docs-green.svg?style=flat)](https://hexdocs.pm/benchmark_ips) [![Hex Version](http://img.shields.io/hexpm/v/benchmark_ips.svg?style=flat)](https://hex.pm/packages/benchmark_ips) [![License](http://img.shields.io/hexpm/l/benchmark_ips.svg?style=flat)](https://github.com/mxhold/benchmark_ips/blob/master/LICENSE)

**Warning: this is a work-in-progress by someone learning Elixir and has not been reviewed by anyone who knows what they're doing.**

BenchmarkIps benchmarks a function and returns how many iterations it can run per second (in wall time). This saves you from having to guess how many times to run something in order to get a meaningful benchmark.

This library is inspired by Evan Phoenix's Ruby library [benchmark-ips](https://github.com/evanphx/benchmark-ips).

## Installation

Add BenchmarkIps to your `mix.exs` file:

~~~elixir
defp deps do
  [
    # ...
    { :benchmark_ips, "~> 0.2.0" },
  ]
end
~~~

Then run `mix deps.get` to fetch everything.

## Usage

Pass in a function to `BenchmarkIps.report` and it will return `{iterations_per_second, microseconds_per_iteration}`:

~~~elixir
iex> BenchmarkIps.report(fn -> :timer.sleep(1_000) end)
{0.9952333299661271, 1004789.5000000001}
~~~

You can also specify how long the warmup time and bench time should be (below are the defaults, in seconds):

~~~elixir
BenchmarkIps.report(fn -> :timer.sleep(1_000) end, warmup_time_s: 1, bench_time_s: 2)
~~~

## Example

An example is included in `examples/list_bench.exs` that compares various operations on lists and tuples.

See `examples/list_bench.md` for the output it generates.
