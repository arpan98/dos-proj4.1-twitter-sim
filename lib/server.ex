defmodule Twitter.Server do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init([]) do
    :ets.new(:registered_users, [:set, :private, :named_table])
    :ets.new(:tweets, [:bag, :private, :named_table])
    :ets.new(:hashtags, [:bag, :private, :named_table])
    :ets.new(:mentions, [:bag, :private, :named_table])
    :ets.new(:subscribers, [:bag, :private, :named_table])
    :ets.new(:subscribed_to, [:bag, :private, :named_table])
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

  def handle_cast({:tweet_post, userId, tweet}, state) do
    time = System.monotonic_time()
    :ets.insert(:tweets, {userId, tweet, time})
    find_hashtags(tweet) |> insert_hashtags(userId, tweet)
    find_mentions(tweet) |> handle_mentions(userId, tweet)
    :ets.lookup(:mentions, 1) |> IO.inspect()
    {:noreply, state}
  end

  def handle_cast({:subscribe, userId, otherId}, state) do
    IO.inspect([userId, otherId])
    if userId != otherId do
      :ets.insert(:subscribers, {otherId, userId})
      :ets.insert(:subscribed_to, {userId, otherId})
    end
    {:noreply, state}
  end

  def handle_call({:get_subscribed_tweets, userId}, _from, state) do
    IO.inspect([userId, " is subscribed to "])
    :ets.lookup(:subscribed_to, userId) |> Enum.map(fn {_, otherId} -> otherId end) |> IO.inspect
    |> Enum.map(fn otherId -> :ets.lookup(:tweets, otherId) |> IO.inspect() end)
    {:reply, state, state}
  end

  defp find_hashtags(tweet) do
    Regex.scan(~r/(#[?<hashtag>\w]+)/, tweet)
  end

  defp find_mentions(tweet) do
    Regex.scan(~r/@([?<hashtag>\w]+)/, tweet)
  end

  defp insert_hashtags(hashtags, userId, tweet) do
    hashtags |> Enum.each(fn [_, capture] ->
      :ets.insert(:hashtags, {capture, userId, tweet})
    end)
  end

  defp insert_mentions(mentions, userId, tweet) do
    mentions |> Enum.each(fn [_, capture] ->
      :ets.insert(:mentions, {String.to_integer(capture), userId, tweet})
    end)
  end

  defp send_tweet_to_mentioned(mentions) do
    :ok
  end

  defp handle_mentions(mentions, userId, tweet) do
    insert_mentions(mentions, userId, tweet)
    send_tweet_to_mentioned(mentions)
  end
end