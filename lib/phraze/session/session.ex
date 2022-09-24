defmodule Phraze.Session.Session do
  @moduledoc false
  alias Phraze.Session.Peer

  defstruct [
    :session_id,
    :action,
    :node,
    :updated_at,
    created_at: DateTime.utc_now(),
    status: :provisioning,
    peers: [%Peer{}]
  ]
end
