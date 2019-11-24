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
    sample_tweet = "@1 hi bro #ToTheStars"
    sample_tweet2 = "Hi @4 #sup #pride"
    Enum.each(users, fn {_, pid} ->
      GenServer.cast(pid, {:tweet, sample_tweet})
      GenServer.cast(pid, {:tweet, sample_tweet2})
    end)
    {_, random_pid} = users |> Enum.random()
    {random_other_id, _} = users |> Enum.random()
    GenServer.cast(random_pid, {:subscribe, random_other_id})
    GenServer.cast(random_pid, :get_subscribed_tweets)
    loop()
  end

  defp loop() do
    receive do
      :end -> exit(:shutdown)
    end
  end
end

Proj4.main(System.argv())