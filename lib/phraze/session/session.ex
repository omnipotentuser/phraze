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

  def new(payload) do
    %__MODULE__{
      session_id: UUID.uuid4(),
      action: payload.action,
      peers: [
        %Peer{
          extension: payload.from_extension,
          user_id: payload.from_user_id
        }
      ]
    }
  end
end
