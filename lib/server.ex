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
    :ets.new(:retweets, [:bag, :private, :named_table])
    {:ok, %{}}
  end

  # Register user
  def handle_call({:register_user, userId, userPid}, from, state) do
    ServerFunctions.register_user(userId, userPid)
    # IO.inspect(["Registered user", userId, userPid])
    {:reply, state, state}
  end

  # Deregister user
  def handle_call({:delete_user, userId}, from, state) do
    ServerFunctions.delete_user(userId)
    {:reply, state, state}
  end

  def handle_call({:login_user, userId}, _, state) do
    ServerFunctions.login(userId)
    {:reply, state, state}
  end

  def handle_call({:logout_user, userId}, _, state) do
    ServerFunctions.logout(userId)
    {:reply, state, state}
  end

  def handle_cast({:tweet_post, userId, tweet}, state) do
    ServerFunctions.tweet(userId, tweet)
    {:noreply, state}
  end

  def handle_cast({:subscribe, userId, otherId}, state) do
    ServerFunctions.subscribe(userId, otherId)
    {:noreply, state}
  end

  def handle_call({:get_subscribed_tweets, userId}, _from, state) do
    ret = ServerFunctions.get_subscribed_tweets(userId)
    {:reply, ret, state}
  end

  def handle_cast({:retweet_post, userId, ownerId, tweet}, state) do
    ServerFunctions.retweet(userId, ownerId, tweet)
    {:noreply, state}
  end

  def handle_call({:get_hashtag_tweets, hashtag}, _from, state) do
    ret = ServerFunctions.get_hashtag_tweets(hashtag)
    {:reply, ret, state}
  end

  def handle_call({:get_mentioned_tweets, userId}, _from, state) do
    ret = ServerFunctions.get_mentioned_tweets(userId)
    {:reply, ret, state}
  end
end