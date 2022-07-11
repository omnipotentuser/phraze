defmodule Phraze.Session.Channel do
  @moduledoc """
  Channel holds individual session information. This also means that each patron
  has its own channel extension number. In a sense, extension numbers are the
  same thing as a channel string.

  So, when users want to connect to each other, we call using the remote peer
  channel value. Or if we want to invite a remote peer to a session, we make
  invite request to the channel of the remote peer. Think of this as a phone
  number. Peers who also wish to join an active session will want to dial to the
  channel which implies the host of the session.
  """
end
