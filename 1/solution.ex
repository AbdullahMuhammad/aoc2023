defmodule ReadInput do
  def readfile(filename) do
    case File.read(filename) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, reason}
    end
  end

end

defmodule Calibration do

  def run(filename) do
    case ReadInput.readfile(filename) do
      {:ok, data} ->
        change_alpha_digits_to_numbers(data)
        |> String.split("\n", trim: true)
        |> get_calibration
        |> IO.inspect
      {:error, reason} -> IO.puts(reason)
    end
  end

  defp change_alpha_digits_to_numbers(s) do
    alpha_indexed_list = [{"zero", "0"}, {"one", "1"}, {"two", "2"}, {"three", "3"}, {"four", "4"}, {"five", "5"}, {"six", "6"}, {"seven", "7"}, {"eight", "8"}, {"nine", "9"}, {"ten", "10"}]
    Enum.reduce(alpha_indexed_list, s, fn ({word, number}, acc) ->
      String.replace(acc, word, ( word <> number <> word ))
    end)
  end

  defp write_digited_string_to_file(data) do
    file_path = "output.txt"
    case File.write(file_path, data) do
      :ok ->
        IO.puts("String successfully written to file.")
      {:error, reason} ->
        IO.puts("Failed to write to file: #{reason}")
    end
  end

  defp get_calibration(list_of_strings) do
    Enum.reduce(list_of_strings, 0, fn (list, acc) ->
      extracted_digits = extract_individual_digits(list)
      {first, last} = {hd(extracted_digits), List.last(extracted_digits)}
      digit_to_be_added = String.to_integer(first <> last)
      digit_to_be_added + acc
    end)
  end

  defp extract_individual_digits(str) do
    Regex.scan(~r/\d/, str)
    |> List.flatten()
  end

end

Calibration.run("test_cases.txt")
