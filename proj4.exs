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
    IO.puts("Registering #{num_users} clients")
    Twitter.registerClients(users)
    
    IO.puts("Setting subscribers randomly")
    Twitter.setSubscribers(users, num_users)
    {_, random_pid} = users |> Enum.random()

    IO.puts("Sending #{num_msgs} tweets per user")
    Twitter.sendTweets(users, num_users, num_msgs)
    
    GenServer.call(random_pid, :get_subscribed_tweets, :infinity)
    GenServer.call(random_pid, {:get_hashtag_tweets, "#gogators"}, :infinity)
    GenServer.call(random_pid, :get_mentioned_tweets, :infinity)

    # Twitter.deregisterClients(users)
    loop()
  end

  defp loop() do
    receive do
      :end -> exit(:shutdown)
    end
  end
end

Proj4.main(System.argv())