defmodule Phraze.Session.Peer do
  @moduledoc false
  defstruct [
    :extension,
    :user_id,
    joined_at: DateTime.utc_now(),
    device: "unknown"
  ]
end
