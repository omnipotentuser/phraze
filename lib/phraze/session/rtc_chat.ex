defmodule Phraze.Session.RtcChat do
  @moduledoc """
  RtcChat holds session of individual connected peer information. This also
  means that each patron has its own extension number. The host's extension will
  be the label of the room. In the future, unique id and call in number will be
  provided.

  So, when users want to connect to each other, the originating peer call using
  the remote peer extension value. If we want to invite a remote peer to an
  already active session, a peer creates invite request to the extension of the
  remote peer. Think of this as a phone number. Peers who also wish to join an
  active session will want to dial to the room which implies the host's
  extension of the session.
  """
end
