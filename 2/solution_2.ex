defmodule ReadInput do
  def readfile(filename) do
    case File.read(filename) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, reason}
    end
  end
end

defmodule Cubes do
  def run(filename) do
    case ReadInput.readfile(filename) do
      {:ok, data} ->
        string_of_strings = String.split(data, "\n", trim: true)
        possible_games(string_of_strings, [], 0) |> IO.inspect
      {:error, reason} -> IO.puts(reason)
    end
  end

  def possible_games([head | tail], valid_games, sum) do
    [game_name, cubes] =
      String.split(head, ":", trim: true)
      |> Enum.map(&String.trim/1)
    turns =
      String.split(cubes, ";", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.split(&1, ","))
    p_map = possibility_map(turns, %{red: 0, green: 0, blue: 0})
    new_sum = sum + Enum.reduce(p_map, 1, fn({_key, val}, acc) ->
      acc * val
    end)
    possible_games(tail, [game_name | valid_games], new_sum)
  end

  def possible_games([], _valid_games, sum), do: sum

  defp possibility_map([], turns_map), do: turns_map

  defp possibility_map([head | tail], turns_map) do
    t_map =
      Enum.map(head, &String.trim/1)
      |> Enum.map(&String.split(&1, " "))
      |> Enum.reduce(turns_map, fn x, acc ->
        k = String.to_atom(List.last(x))
        new_acc = if String.to_integer(hd(x)) >= acc[k] do
          Map.put(acc, k, String.to_integer(hd(x)))
        else
          acc
        end
        new_acc
      end)
    possibility_map(tail, t_map)
  end
end

Cubes.run("test_cases.txt")
