defmodule Twitter.Server do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init([]) do
    :ets.new(:registered_users, [:set, :private, :named_table])
    {:ok, %{}}
  end

  # Register user
  def handle_call({:register_user, userId}, from, state) do
    {userPid, _} = from
    :ets.insert(:registered_users, {userId, userPid})
    IO.inspect(["Registered user", userId, userPid])
    {:reply, state, state}
  end

  # Deregister user
  def handle_call({:delete_user, userId}, from, state) do
    {_, registeredPid} = :ets.lookup(:registered_users, userId) |> Enum.at(0)
    {fromPid, _} = from
    if fromPid == registeredPid do
      :ets.delete(:registered_users, userId)
    end
    {:reply, state, state}
  end
end