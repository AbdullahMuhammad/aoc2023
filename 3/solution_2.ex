defmodule ReadInput do
  def readfile(filename) do
    case File.read(filename) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, reason}
    end
  end

end

defmodule Engine do

  def run(filename) do
    case ReadInput.readfile(filename) do
      {:ok, data} ->
        String.split(data, "\n", trim: true)
        |> sum_parts
        |> IO.inspect
      {:error, reason} -> IO.puts(reason)
    end
  end

  def sum_parts(strings_list) do
    indexed_strings = Enum.with_index(strings_list)
    sym_map = get_sym_map(indexed_strings)
    nums_map = get_nums_map(indexed_strings, %{})
    flat_nums_map =
      Enum.map(nums_map, fn {k, v} -> {k, Enum.flat_map(v, & &1)} end)
      |> Enum.into(%{})
    lets_sum_with_elegance(indexed_strings, sym_map, flat_nums_map)
  end

  defp lets_sum_with_elegance(indexed_list, sym_map, flat_nums_map) do
    [head | tail] = Map.keys(sym_map)
    sum_adjacent([head | tail], indexed_list, flat_nums_map, sym_map, 0)
  end

  defp sum_adjacent([], _, _, _, net_sum), do: net_sum
  defp sum_adjacent([head | tail], indexed_list, nums_map, sym_map, net_sum) do
    {row_number, symbol_start} = head
    # this time we are running based on Symbols map or * map ;)

    prev = row_number - 1
    next = row_number + 1
    nums_above = nums_map[prev]
    nums_current = nums_map[row_number]
    nums_below = nums_map[next]

    # check above for adjacent numbers
    # lets start with symbol start
    n_above = Enum.filter(nums_above, fn {st, len} ->
      symbol_start >= (st - 1) && symbol_start <= st + len
    end)
    |> Enum.map(fn {st, len} ->
      {str, _} = Enum.at(indexed_list, prev)
      String.slice(str, st, len)
    end)

    n_current = Enum.filter(nums_current, fn {st, len} ->
      symbol_start >= (st - 1) && symbol_start <= st + len
    end)
    |> Enum.map(fn {st, len} ->
      {str, _} = Enum.at(indexed_list, row_number)
      String.slice(str, st, len)
    end)

    n_below = Enum.filter(nums_below, fn {st, len} ->
      symbol_start >= (st - 1) && symbol_start <= (st + len)
    end)
    |> Enum.map(fn {st, len} ->
      {str, _} = Enum.at(indexed_list, next)
      String.slice(str, st, len)
    end)

    number_to_be_mult = List.flatten([n_above, n_current, n_below])
    product = if length(number_to_be_mult) > 1 do
      Enum.reduce(number_to_be_mult, 1, fn (x, prod) ->
        prod * String.to_integer(x)
      end)
    else
      0
    end

    sum_adjacent(tail, indexed_list, nums_map, sym_map, net_sum + product)
  end

  defp get_nums_map([], mp), do: mp

  defp get_nums_map([head | tail], m) do
    {string, y_index} = head
    mp = ext_nums_frm_str(string, y_index)
    merged_map = Map.merge(m, mp)
    get_nums_map(tail, merged_map)
  end

  defp ext_nums_frm_str(s, y_index) do
    regex = ~r/\d+/
    indexes_list = Regex.scan(regex, s, return: :index)
    Map.put(%{}, y_index, indexes_list)
  end

  defp get_sym_map(indexed_strings) do
    Enum.reduce(indexed_strings, %{}, fn {string, index}, acc ->
      String.graphemes(string)
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {char, char_index}, acc_inner ->
        if char == "*" do
          key = {index, char_index}
          Map.update(acc_inner, key, char, fn _existing -> char end)
        else
          acc_inner
        end
      end)
    end)
  end

end

Engine.run("test_cases.txt")
