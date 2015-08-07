defmodule BenchmarkIps do
  def call_times(fun, 1), do: fun.()
  def call_times(fun, times) do
    fun.()
    call_times(fun, times - 1)
  end

  @doc """
  Returns the number of cycles a function can run in 100ms
  """
  def cycles_per_100ms(fun) do
    {iters, time_us} = warmup(fun)
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

  @doc """
  Runs the provided function repeatedly for 2 seconds and
  returns the number of iterations and total time
  """
  def warmup(fun, duration_s \\ 1) do
    start = now_us
    target = now_us + (duration_s * 1.0e6)

    iters = do_warmup(fun, target, 0)

    finish = now_us

    warmup_time_us = finish - start

    {iters, warmup_time_us}
  end

  def do_warmup(fun, target, iters) do
    if now_us < target do
      fun.()
      do_warmup(fun, target, iters + 1)
    else
      iters
    end
  end

  def ips(fun) do
    {iters, time_us} = bench(fun)
    time_s = time_us * 1.0e-6
    iters / time_s
  end

  def bench(fun, duration_s \\ 2) do
    cycles = cycles_per_100ms(fun)

    start = now_us
    target = now_us + (duration_s * 1.0e6)

    iters = do_bench(fun, cycles, target, 0)

    finish = now_us

    time_us = finish - start

    {iters, time_us}
  end

  def do_bench(fun, cycles, target, iters) do
    if now_us < target do
      call_times(fun, cycles)
      do_bench(fun, cycles, target, iters + 1)
    else
      iters * cycles
    end
  end

  @doc """
  Returns current time in microseconds
  """
  def now_us do
    # {megaseconds, seconds, microseconds} = :erlang.now
    # microseconds + (seconds * 1.0e6) + (megaseconds * 1.0e12)
    :erlang.monotonic_time(:micro_seconds)
  end

  def report(fun) do
    ips = ips(fun)
    uspi = (1 / ips) * 1.0e6
    {ips, uspi}
  end

  def list_bench do
    lists = [
      "10k": Enum.to_list(1..10_000),
      "100k": Enum.to_list(1..100_000),
      "1m": Enum.to_list(1..1_000_000),
      "2m": Enum.to_list(1..2_000_000),
      "5m": Enum.to_list(1..5_000_000),
      "8m": Enum.to_list(1..5_000_000),
      "10m": Enum.to_list(1..10_000_000)
    ]

    list_operations = [
      "length": fn list -> length list end,
      "prepend": fn list -> [1|list] end,
      "append": fn list -> list ++ [1] end,
      "access first": fn list -> hd list end,
      "access last": fn list -> List.last list end,
    ]

    IO.puts "# Lists"
    report_each(lists, list_operations)

    tuples = lists |> Enum.map(fn {label, list} -> {label, List.to_tuple(list)} end)

    tuple_operations = [
      "length": fn tuple -> tuple_size(tuple) end,
      "prepend": fn tuple -> Tuple.insert_at(tuple, 0, 1) end,
      "append": fn tuple -> Tuple.insert_at(tuple, tuple_size(tuple) - 1, 1) end,
      "access first": fn tuple -> elem(tuple, 0) end,
      "access last": fn tuple -> elem(tuple, tuple_size(tuple) - 1) end,
    ]

    IO.puts "\n# Tuples"
    report_each(tuples, tuple_operations)
  end

  def report_each(collection, operations) do
    operations
    |> Enum.map(fn {label, fun} ->
      IO.puts "\n## #{label |> to_string |> String.capitalize}\n"
      IO.puts "#{String.rjust("label", 10)} #{String.rjust("i/ps", 15)} #{String.rjust("μ/i", 15)}"
      do_with_each(collection, fun)
    end)
  end


  def do_with_each(collection, fun) do
    collection
    |> Enum.map(fn {label, element} ->
      {ips, uspi} = report(fn -> fun.(element) end)
      label_part = String.rjust(label |> to_string, 10)
      ips_part = pad_float(ips, 15)
      uspi_part = pad_float(uspi, 15)
      IO.puts "#{label_part} #{ips_part} #{uspi_part}"
    end)
  end

  def pad_float(float, padding) do
    :io_lib.format("~.2f", [float]) |> hd |> to_string |> String.rjust(padding)
  end
end
