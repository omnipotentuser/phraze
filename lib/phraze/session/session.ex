defmodule Phraze.Session.Session do
  @moduledoc false
  defstruct [
    :session_id,
    :action,
    :node,
    :updated_at,
    created_at: DateTime.utc_now(),
    status: :provisioning,
    peers: []
  ]
end
