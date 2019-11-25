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
    users |> Enum.map(fn {_, pid} -> 
      GenServer.cast(pid, :register)
    end)
  end

  def deregisterClients(users) do
    users |> Enum.map(fn {_, pid} ->
      GenServer.cast(pid, :delete)
    end)
  end

  def sendTweets(users, num_users, num_msgs) do
    Enum.each(users, fn {id, pid} ->
      Enum.each(1..10, fn i ->
        tweet = generateRandomTweet(id, num_users)
        GenServer.cast(pid, {:tweet, tweet})
      end)
    end)
  end

  defp generateRandomTweet(userId, num_users) do
    hashtags = getRandomHashtags()
    # IO.inspect(["hashtags", hashtags])
    mentions = getRandomMentions(userId, num_users)
    # IO.inspect(["mentions", mentions])
    tweet = Enum.reduce(mentions, "Hello", fn otherId, acc -> "#{acc} @#{to_string(otherId)}" end)
    tweet = Enum.reduce(hashtags, tweet, fn ht, acc -> "#{acc} #{ht}" end)
  end

  defp getRandomHashtags() do
    hashtags = ["#uf", "#gogators", "#twitter"]
    num_hashtags = Enum.random(0..2)
    Enum.take_random(hashtags, num_hashtags)
  end

  defp getRandomMentions(userId, num_users) do
    num_mentions = Enum.random(0..2)
    othersList = 1..num_users |> Enum.to_list() |> List.delete(userId)
    Enum.reduce(1..num_mentions, [], fn i, acc ->
      [Enum.random(othersList) | acc]
    end)
  end
end
