defmodule ListBench do
  def run do
    lists = [
      "10k": Enum.to_list(1..10_000),
      "100k": Enum.to_list(1..100_000),
      "1m": Enum.to_list(1..1_000_000),
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
      IO.puts "#{String.rjust("label", 10)} #{String.rjust("i/s", 15)} #{String.rjust("μ/i", 15)}"
      do_with_each(collection, fun)
    end)
  end

  def do_with_each(collection, fun) do
    collection
    |> Enum.map(fn {label, element} ->
      {ips, uspi} = BenchmarkIps.report(fn -> fun.(element) end)
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

ListBench.run
