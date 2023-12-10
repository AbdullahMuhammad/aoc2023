defmodule ReadInput do
  def readfile(filename) do
    case File.read(filename) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, reason}
    end
  end
end

defmodule Cards do

  def run(filename) do
    case ReadInput.readfile(filename) do
      {:ok, data} ->
        string_of_strings = String.split(data, "\n", trim: true)
        sum_winning_cards(string_of_strings) |> IO.inspect
      {:error, reason} -> IO.puts(reason)
    end
  end

  def sum_winning_cards(strings_list) do
    sum_cards(strings_list, 0)
  end

  defp sum_cards([], sum), do: sum
  defp sum_cards([head | tail], sum) do

    [_ | combos] = String.split(head, ":", trim: true)
    [winning_numbers, revealed_numbers | _] = String.split(hd(combos), "|", trim: true)
    # winning_numbers = " 41 48 83 86 17 "

    winning_numbers_map = String.split(winning_numbers, " ", trim: true)
    |> Enum.reduce( %{}, fn(x, mp) ->
      Map.put(mp, x, 1)
    end )

    number_of_matches = String.split(revealed_numbers, " ", trim: true)
    |> Enum.reduce(0, fn(x, acc) ->
        if winning_numbers_map[x] do
          acc + 1
        else
          acc
        end
      end)
    s = :math.pow(2, (number_of_matches - 1))
    |> trunc
    sum_cards(tail, (sum + s))
  end

end

Cards.run("test_cases.txt")
