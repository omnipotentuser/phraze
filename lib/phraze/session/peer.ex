defmodule Phraze.Session.Peer do
  @moduledoc """
    Peer is an user agent actively participating in a session
  """
  defstruct [
    :extension,
    :user_id,
    joined_at: DateTime.utc_now(),
    device: "unknown"
  ]
end
