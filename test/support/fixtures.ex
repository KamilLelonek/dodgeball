defmodule Dodgeball.Test.Fixtures do
  @moduledoc false

  @dir Path.expand("../fixtures", __DIR__)

  @spec read(String.t()) :: String.t()
  def read(filename) when is_binary(filename) do
    @dir
    |> Path.join(filename)
    |> File.read!()
  end
end
