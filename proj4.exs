defmodule Proj4 do
  def main(args) do
    args
    |> parse_input
    |> run
  end

  defp parse_input([num_users, num_msgs]) do
    [String.to_integer(num_users), String.to_integer(num_msgs)]
  end

  defp run([num_users, num_msgs]) do
    Twitter.startServer()
    users = Twitter.startClients(num_users)
    Twitter.registerClients(users)
    Twitter.deregisterClients(users)
    loop()
  end

  defp loop() do
    receive do
      :end -> exit(:shutdown)
    end
  end
end

Proj4.main(System.argv())