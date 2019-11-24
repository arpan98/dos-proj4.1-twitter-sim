defmodule Twitter.Client do
  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def init([userId]) do
    {:ok, %{userId: userId}}
  end

  def handle_cast(:register, state) do
    GenServer.call(TwitterServer, {:register_user, state.userId})
    {:noreply, state}
  end

  def handle_cast(:delete, state) do
    GenServer.call(TwitterServer, {:delete_user, state.userId})
    {:noreply, state}
  end

  def handle_cast({:tweet, tweet}, state) do
    GenServer.cast(TwitterServer, {:tweet_post, state.userId, tweet})
    {:noreply, state}
  end

  def handle_cast({:subscribe, otherId}, state) do
    GenServer.cast(TwitterServer, {:subscribe, state.userId, otherId})
    {:noreply, state}
  end

  def handle_cast(:get_subscribed_tweets, state) do
    GenServer.call(TwitterServer, {:get_subscribed_tweets, state.userId}) |> IO.inspect()
  end
end