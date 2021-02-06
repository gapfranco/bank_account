defmodule DatabaseSeeder do
  def load_data(filename) do
    with {:ok, body} <- File.read(filename), {:ok, json} <- Poison.decode(body), do: {:ok, json}
  end
end
