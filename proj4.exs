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
    Twitter.sendTweets(users, num_users, num_msgs)
    {_, random_pid} = users |> Enum.random()
    Enum.take_random(users, 3) |> Enum.each(fn {otherId, _} ->
      GenServer.cast(random_pid, {:subscribe, otherId})
    end)
    GenServer.call(random_pid, :get_subscribed_tweets)
    GenServer.call(random_pid, {:get_hashtag_tweets, "#gogators"})
    GenServer.call(random_pid, :get_mentioned_tweets)
    loop()
  end

  defp loop() do
    receive do
      :end -> exit(:shutdown)
    end
  end
end

Proj4.main(System.argv())