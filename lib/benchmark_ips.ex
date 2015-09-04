defmodule BenchmarkIps do
  @typep zero_arity_fun :: (() -> any)

  @doc """
  Returns current time in microseconds
  """
  @spec now_us() :: pos_integer
  def now_us do
    :erlang.monotonic_time(:micro_seconds)
  end

  @doc """
  Calls the function the specified number of times
  """
  @spec call_times(zero_arity_fun, pos_integer) :: nil
  def call_times(fun, times) do
    fun.()

    if times > 1 do
      call_times(fun, times - 1)
    end
  end

  @doc """
  Returns the result of running a function and the time it took to run in microseconds
  """
  @spec measure_in_us(zero_arity_fun) :: {any, number}
  def measure_in_us(fun) do
    start = now_us
    result = fun.()
    finish = now_us
    {result, finish - start}
  end

  @doc """
  Returns the number of iterations that should be able to be run in 100ms given a number
  of iterations and a duration in microseconds
  """
  @spec iterations_per_100ms(pos_integer, number) :: pos_integer
  def iterations_per_100ms(iters, time_us) do
    time_ms = time_us * 1.0e-3
    iterations_per_ms = iters / time_ms
    batches = iterations_per_ms * 100
    batches = round(batches)
    if batches <= 0 do
      1
    else
      batches
    end
  end

  @doc """
  Returns the number of iterations a function can run in the provided duration (microseconds) by
  running it in batches and checking between batches on the time elapsed
  """
  @spec iterations_runnable_in_duration_by_batches(zero_arity_fun, pos_integer, number) :: pos_integer
  def iterations_runnable_in_duration_by_batches(fun, batches, target_duration_us) do
    iterations_runnable_in_duration_by_batches(fun, batches, now_us + target_duration_us, 0)
  end

  def iterations_runnable_in_duration_by_batches(fun, batches, target_end_time_us, iters) do
    if now_us < target_end_time_us do
      call_times(fun, batches)
      iterations_runnable_in_duration_by_batches(fun, batches, target_end_time_us, iters + 1)
    else
      iters * batches
    end
  end

  @doc """
  Returns the number of iterations and elapsed time of running a function in batches for the
  provided target duration (seconds)
  """
  @spec bench(zero_arity_fun, pos_integer, number) :: {pos_integer, number}
  def bench(fun, batches, target_duration_s) do
    target_duration_us = target_duration_s * 1.0e6

    {iters, actual_time_us} = measure_in_us(fn ->
      iterations_runnable_in_duration_by_batches(fun, batches, target_duration_us)
    end)

    {iters, actual_time_us}
  end

  @doc """
  Benchmarks a function and returns the iterations per second and microseconds per iterations

  The function is first benchmarked for the provided warmup duration (seconds, default 1) in
  batches of 1 in order to determine about how many iterations can run in 100ms.

  It is then benchmarked in batches of that number of iterations for the provided bench duration
  (seconds, default 2).
  """
  @spec report(zero_arity_fun, [warmup_duration_s: number, bench_duration_s: number]) :: {float, float}
  def report(fun, options \\ []) do
    warmup_duration_s = Keyword.get(options, :warmup_duration_s, 1)
    bench_duration_s = Keyword.get(options, :bench_duration_s, 2)

    {warmup_iters, warmup_time_us} = bench(fun, 1, warmup_duration_s)

    warmup_iterations_per_100ms = iterations_per_100ms(warmup_iters, warmup_time_us)

    {actual_iters, actual_time_us} = bench(fun, warmup_iterations_per_100ms, bench_duration_s)

    iters_per_us = actual_iters / actual_time_us

    us_per_iter = 1 / iters_per_us
    iters_per_s = iters_per_us * 1.0e6

    {iters_per_s, us_per_iter}
  end
end
