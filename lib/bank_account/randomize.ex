defmodule BankAccount.Randomizer do
  @moduledoc """
  Random string generator module.
  """

  def randomizer(length) do
    alphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    numbers = "0123456789"

    lists =
      (alphabets <> String.downcase(alphabets) <> numbers)
      |> String.split("", trim: true)

    do_randomizer(length, lists)
  end

  @doc false
  defp get_range(length) when length > 1, do: 1..length
  defp get_range(_length), do: [1]

  @doc false
  defp do_randomizer(length, lists) do
    get_range(length)
    |> Enum.reduce([], fn _, acc -> [Enum.random(lists) | acc] end)
    |> Enum.join("")
  end
end
