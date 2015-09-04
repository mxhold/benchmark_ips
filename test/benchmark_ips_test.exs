defmodule BenchmarkIpsTest do
  use ExUnit.Case

  def assert_in_delta_factor(actual, expected, delta_factor, message \\ nil) do
    assert_in_delta(actual, expected, delta_factor * expected, message)
  end

  @allowed_delta_factor 0.3
  @warmup_duration_s 0.1
  @main_duration_s 0.2

  test "results make sense using sleep" do
    [10, 50, 100] |> Enum.each(fn time_ms ->
      expected_ips = 1 / (time_ms * 1.0e-3)
      expected_uspi = time_ms * 1.0e3

      {actual_ips, actual_uspi} = BenchmarkIps.report(fn ->
        :timer.sleep(time_ms)
      end, warmup_duration_s: @warmup_duration_s, bench_duration_s: @main_duration_s)

      assert_in_delta_factor actual_ips, expected_ips, @allowed_delta_factor
      assert_in_delta_factor actual_uspi, expected_uspi, @allowed_delta_factor
    end)
  end
end
