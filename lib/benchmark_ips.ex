defmodule BenchmarkIps do
  @typedoc """
  A function with zero arity
  """
  @type zero_arity_fun :: (() -> any)

  @doc """
  Returns current time in microseconds
  """
  def now_us do
    :erlang.monotonic_time(:micro_seconds)
  end

  @doc """
  Calls the function the specified number of times
  """
  def call_times(fun, 1), do: fun.()
  def call_times(fun, times) do
    fun.()
    call_times(fun, times - 1)
  end

  @doc """
  Returns the result of running a function and the time it took to run in microseconds
  """
  def measure_in_us(fun) do
    start = now_us
    result = fun.()
    finish = now_us
    {result, finish - start}
  end

  def cycles_per_100ms(iters, time_us) do
    time_ms = time_us * 1.0e-3
    cycles_per_ms = iters / time_ms
    cycles = cycles_per_ms * 100
    cycles = round(cycles)
    if cycles <= 0 do
      1
    else
      cycles
    end
  end

  def iterations_runnable_in_duration_by_cycles(fun, cycles, target_duration_us) do
    iterations_runnable_in_duration_by_cycles(fun, cycles, now_us + target_duration_us, 0)
  end

  def iterations_runnable_in_duration_by_cycles(fun, cycles, target_end_time_us, iters) do
    if now_us < target_end_time_us do
      call_times(fun, cycles)
      iterations_runnable_in_duration_by_cycles(fun, cycles, target_end_time_us, iters + 1)
    else
      iters * cycles
    end
  end

  def bench(fun, cycles, target_duration_s) do
    target_duration_us = target_duration_s * 1.0e6

    {iters, actual_time_us} = measure_in_us(fn ->
      iterations_runnable_in_duration_by_cycles(fun, cycles, target_duration_us)
    end)

    {iters, actual_time_us}
  end

  def report(fun, options \\ []) do
    warmup_duration_s = Keyword.get(options, :warmup_duration_s, 1)
    bench_duration_s = Keyword.get(options, :bench_duration_s, 2)

    {warmup_iters, warmup_time_us} = bench(fun, 1, warmup_duration_s)

    warmup_cycles_per_100ms = cycles_per_100ms(warmup_iters, warmup_time_us)

    {actual_iters, actual_time_us} = bench(fun, warmup_cycles_per_100ms, bench_duration_s)

    iters_per_us = actual_iters / actual_time_us

    us_per_iter = 1 / iters_per_us
    iters_per_s = iters_per_us * 1.0e6

    {iters_per_s, us_per_iter}
  end
end
