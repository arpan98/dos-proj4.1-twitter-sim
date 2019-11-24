defmodule Twitter do
  def startServer() do
    GenServer.start_link(Twitter.Server, [], name: TwitterServer)
    GenServer.call(TwitterServer, {:register_user, 0})
  end

  def startClients(num_users) do
    children = 1..num_users
    |> Enum.map(fn i ->
      Supervisor.child_spec({Twitter.Client, [i]}, id: {Twitter.Client, i})
    end)
    Supervisor.start_link(children, strategy: :one_for_one, name: ClientSupervisor)

    Enum.map(Supervisor.which_children(ClientSupervisor), fn client ->
      {{_, id}, pid, _, _} = client
      {id, pid}
    end)
  end

  def registerClients(users) do
    users |> Enum.map(fn {id, pid} -> 
      GenServer.cast(pid, :register)
    end)
  end

  def deregisterClients(users) do
    users |> Enum.map(fn {id, pid} ->
      GenServer.cast(pid, :delete)
    end)
  end
end
