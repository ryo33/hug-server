defmodule Input do
  @enforce_keys [:id, :payload]
  defstruct @enforce_keys
end

defmodule Output do
  @enforce_keys [:id, :payload]
  defstruct @enforce_keys
end

# event to join a random room
defmodule JoinRandom do
  @enforce_keys [:id]
  defstruct @enforce_keys
end

# event to join the room with key
defmodule JoinRoom do
  @enforce_keys [:id, :key]
  defstruct @enforce_keys
end

# event to create a room
defmodule CreateRoom do
  @enforce_keys [:id]
  defstruct @enforce_keys
end

# the key of room
defmodule RoomCreated do
  @enforce_keys [:id, :key]
  defstruct @enforce_keys
end

# Second one wait for this event
defmodule Joined do
  @enforce_keys [:id, :room_id, :is_primary]
  defstruct @enforce_keys
end

# Room not found
defmodule NotFound do
  @enforce_keys [:id]
  defstruct @enforce_keys
end

defmodule Push do
  @enforce_keys [:id, :payload]
  defstruct @enforce_keys
end
