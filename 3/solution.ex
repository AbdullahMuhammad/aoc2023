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
    [head | tail] = Map.keys(flat_nums_map)
    sum_at_row([head | tail], indexed_list, flat_nums_map, sym_map, 0)
  end

  defp sum_at_row([], _, _, _, net_sum), do: net_sum
  defp sum_at_row([head | tail], indexed_list, nums_map, sym_map, net_sum) do
    row_number = head
    row_sum =
      nums_map[row_number]
      |> Enum.reduce(0, fn {start, length}, sum_acc ->
        lookout_pairs =
          Enum.map((start - 1)..(start + length), fn y ->
            prev = row_number - 1
            next = row_number + 1
            %{{prev, y} => 1, {row_number, y} => 1, {next, y} => 1}
          end)

        merged_map =
          Enum.reduce(lookout_pairs, %{}, fn map, acc ->
            Map.merge(acc, map)
          end)
        result = contains_sym_map_element?(sym_map, merged_map)
        if result do
          {str, _} = Enum.at(indexed_list, row_number)
          substring = String.slice(str, start, length)
          sum_acc + String.to_integer(substring)
        else
          sum_acc
        end
      end)
    sum_at_row(tail, indexed_list, nums_map, sym_map, net_sum + row_sum)
  end

  defp contains_sym_map_element?(sym_map, merged_map) do
    Enum.any?(sym_map, fn {key, _value} ->
      Map.has_key?(merged_map, key)
    end)
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
        if not Regex.match?(~r/^\d|\.|\r$/, char) do
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
