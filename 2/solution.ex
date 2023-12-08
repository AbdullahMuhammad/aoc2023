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
    max_cubes = %{red: 12, green: 13, blue: 14}

    [game_name, cubes] =
      String.split(head, ":", trim: true)
      |> Enum.map(&String.trim/1)

    turns =
      String.split(cubes, ";", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.split(&1, ","))

    is_game_valid = check_validity(turns, %{red: 0, green: 0, blue: 0}, max_cubes, true)
    if is_game_valid do
      game_num = List.last(String.split(game_name, " "))
      |> String.to_integer
      possible_games(tail, [game_name | valid_games], sum + game_num)
    else
      possible_games(tail, valid_games, sum)
    end
  end

  def possible_games([], _valid_games, sum), do: sum

  defp valid_game?(max_cubes, turns_map) do
    Enum.all?(turns_map, fn {key, value} ->
      case max_cubes[key] do
        nil -> false
        max_value -> value <= max_value
      end
    end)
  end

  defp check_validity([], _turns_map, _max_cubes, bln_valid), do: bln_valid

  defp check_validity(_, _turns_map, _max_cubes, false), do: false

  defp check_validity([head | tail], turns_map, max_cubes, _) do
    t_map =
      Enum.map(head, &String.trim/1)
      |> Enum.map(&String.split(&1, " "))
      |> Enum.reduce(turns_map, fn x, acc ->
        k = String.to_atom(List.last(x))
        Map.put(acc, k, acc[k] + String.to_integer(hd(x)))
      end)
    is_valid = valid_game?(max_cubes, t_map)
    check_validity(tail, %{red: 0, green: 0, blue: 0}, max_cubes, is_valid)
  end
end

Cubes.run("test_cases.txt")
