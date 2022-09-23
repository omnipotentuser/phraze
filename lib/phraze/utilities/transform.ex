defmodule Phraze.Utilities.Transform do
  @moduledoc false

  def action_to_atom(str), do: action_to_atom_p(str)

  defp action_to_atom_p("login"), do: :login
  defp action_to_atom_p("join_channel"), do: :join_channel
  defp action_to_atom_p("call"), do: :call
  defp action_to_atom_p("message"), do: :message
  defp action_to_atom_p("vri_call"), do: :vri_call
  defp action_to_atom_p("vri_terp_join"), do: :vri_terp_join
  defp action_to_atom_p("sdp"), do: :sdp
  defp action_to_atom_p("ice_candidate"), do: :ice_candidate
  defp action_to_atom_p(_), do: :unknown_action
end
