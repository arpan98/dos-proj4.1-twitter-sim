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
    find_mentions(tweet) |> insert_mentions(userId, tweet)
    :ets.lookup(:hashtags, "#ToTheStars") |> IO.inspect()
    {:noreply, state}
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
      :ets.insert(:mentions, {capture, userId, tweet})
    end)
  end
end