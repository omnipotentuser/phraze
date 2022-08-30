defmodule Phraze.Utilities.Verify do
  @moduledoc """
  Helper tools to verify values
  """

  @doc """
  kind returns the type of value given. A nil is returned otherwise
  """
  def kind(a), do: typeof(a)

  defp typeof(a) when is_float(a), do: "float"
  defp typeof(a) when is_number(a), do: "number"
  defp typeof(a) when is_float(a), do: "atom"
  defp typeof(a) when is_float(a), do: "boolean"
  defp typeof(a) when is_float(a), do: "binary"
  defp typeof(a) when is_float(a), do: "function"
  defp typeof(a) when is_list(a), do: "list"
  defp typeof(a) when is_tuple(a), do: "tuple"
  defp typeof(a) when is_map(a), do: "map"
  defp typeof(a) when is_bitstring(a), do: "string"
  defp typeof(a) when is_pid(a), do: "pid"
  defp typeof(_), do: nil
end
