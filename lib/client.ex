defmodule Twitter.Client do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init([userId]) do
    {:ok, %{userId: userId}}
  end

  def addSubscribedTo(userId, otherId) do
    GenServer.cast(TwitterServer, {:subscribe, userId, otherId})
  end

  def handle_cast(:register, state) do
    GenServer.call(TwitterServer, {:register_user, state.userId, self()}, :infinity)
    {:noreply, state}
  end

  def handle_cast(:delete, state) do
    GenServer.call(TwitterServer, {:delete_user, state.userId}, :infinity)
    {:noreply, state}
  end

  def handle_cast(:login, state) do
    GenServer.call(TwitterServer, {:login_user, state.userId}, :infinity)
    {:noreply, state}
  end

  def handle_cast(:logout, state) do
    GenServer.call(TwitterServer, {:logout_user, state.userId}, :infinity)
    {:noreply, state}
  end

  def handle_cast({:tweet, tweet}, state) do
    GenServer.cast(TwitterServer, {:tweet_post, state.userId, tweet})
    {:noreply, state}
  end

  def handle_cast({:retweet, ownerId, tweet}, state) do
    GenServer.call(TwitterServer, {:retweet_post, state.userId, ownerId, tweet}, :infinity)
    {:noreply, state}
  end

  def handle_cast({:subscribe, otherId}, state) do
    GenServer.cast(TwitterServer, {:subscribe, state.userId, otherId})
    {:noreply, state}
  end

  def handle_call(:get_subscribed_tweets, _from, state) do
    ret = GenServer.call(TwitterServer, {:get_subscribed_tweets, state.userId}, :infinity)
    {:reply, ret, state}
  end

  def handle_call({:get_hashtag_tweets, hashtag}, _from, state) do
    IO.puts("\nQuery for #{hashtag}")
    ret = GenServer.call(TwitterServer, {:get_hashtag_tweets, hashtag}, :infinity)
    IO.puts("Got #{Enum.count(ret)} tweets")
    Enum.each(Enum.take(ret, 10), fn {userId, tweet, _} ->
      IO.puts("User: #{userId} - #{tweet}")
    end)
    IO.puts("...")
    {:reply, ret, state}
  end

  def handle_call(:get_mentioned_tweets, _from, state) do
    IO.puts("\nQuery for @#{state.userId}")
    ret = GenServer.call(TwitterServer, {:get_mentioned_tweets, state.userId}, :infinity)
    IO.puts("Got #{Enum.count(ret)} tweets")
    Enum.each(Enum.take(ret, 10), fn {userId, tweet, _} ->
      IO.puts("User: #{userId} - #{tweet}")
    end)
    if Enum.count(ret) > 10 do
      IO.puts("...")
    end
    {:reply, ret, state}
  end

  def handle_cast({:receive_tweet, userId, tweet, source}, state) do
    # case source do
    #   :subscribe -> IO.puts("Subscriptions - #{state.userId} received tweet from #{userId} - #{tweet}")
    #   :mention -> IO.puts("#{userId} mentioned you(#{state.userId}) in their tweet - #{tweet}")
    #   _ -> IO.puts("#{state.userId} received tweet from #{userId} - #{tweet}")
    # end
    # case probability_roll(0.5) do
    #   true -> GenServer.cast(TwitterServer, {:retweet_post, state.userId, userId, tweet})
    #   false -> :nothing
    # end
    {:noreply, state}
  end

  def handle_cast({:receive_retweet, userId, ownerId, tweet}, state) do
    # IO.puts("#{state.userId} received retweet. #{userId} retweeted #{ownerId} - #{tweet}")
    {:noreply, state}
  end

  defp probability_roll(p) do
    roll = :rand.uniform()
    if roll <= p, do: true, else: false
  end
end