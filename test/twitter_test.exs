defmodule TwitterTest do
  use ExUnit.Case
  doctest Twitter

  @userId 6
  @userPid 6
  @otherId 3
  @tweet "hello @6 #gogators"

  test "registration test" do
    :ets.new(:registered_users, [:set, :private, :named_table])
    assert :ets.whereis(:registered_users) != :undefined
    ServerFunctions.register_user(@userId, @userPid)
    assert :ets.member(:registered_users, @userId) == true
  end

  test "deregistration test" do
    :ets.new(:registered_users, [:set, :private, :named_table])
    assert :ets.whereis(:registered_users) != :undefined
    ServerFunctions.register_user(@userId, @userPid)
    ServerFunctions.delete_user(@userId)
    assert :ets.member(:registered_users, @userId) == false
  end

  test "login test" do
    :ets.new(:registered_users, [:set, :private, :named_table])
    assert :ets.whereis(:registered_users) != :undefined
    ServerFunctions.register_user(@userId, @userPid)
    ServerFunctions.login(@userId)
    assert ServerFunctions.is_user_connected(@userId)
  end

  test "logout test" do
    :ets.new(:registered_users, [:set, :private, :named_table])
    assert :ets.whereis(:registered_users) != :undefined
    ServerFunctions.register_user(@userId, @userPid)
    ServerFunctions.login(@userId)
    ServerFunctions.logout(@userId)
    assert not ServerFunctions.is_user_connected(@userId)
  end

  test "tweet" do
    :ets.new(:tweets, [:bag, :private, :named_table])
    :ets.new(:hashtags, [:bag, :private, :named_table])
    :ets.new(:mentions, [:bag, :private, :named_table])
    ServerFunctions.tweet(@userId, @tweet, false)
    assert :ets.lookup(:tweets, @userId) |> Enum.find(false, fn {_, t, _} -> t == @tweet end)
  end

  test "extract hashtag from tweet test" do
    :ets.new(:tweets, [:bag, :private, :named_table])
    :ets.new(:hashtags, [:bag, :private, :named_table])
    :ets.new(:mentions, [:bag, :private, :named_table])
    ServerFunctions.tweet(@userId, @tweet, false)
    assert :ets.lookup(:hashtags, "#gogators") |> Enum.find(false, fn {ht, _, _} -> ht == "#gogators" end)
  end

  test "extract mention from tweet test" do
    :ets.new(:tweets, [:bag, :private, :named_table])
    :ets.new(:hashtags, [:bag, :private, :named_table])
    :ets.new(:mentions, [:bag, :private, :named_table])
    ServerFunctions.tweet(@userId, @tweet, false)
    assert :ets.lookup(:mentions, @userId) |> Enum.find(false, fn {uid, _, _} -> uid == @userId end)
  end

  test "subscribe test" do
    :ets.new(:subscribers, [:bag, :private, :named_table])
    :ets.new(:subscribed_to, [:bag, :private, :named_table])
    ServerFunctions.subscribe(@userId, @otherId)
    assert :ets.lookup(:subscribers, @otherId) |> Enum.find(false, fn {_, uid} -> uid == @userId end)
    assert :ets.lookup(:subscribed_to, @userId) |> Enum.find(false, fn {_, uid} -> uid == @otherId end)
  end

  test "retweet test" do
    :ets.new(:retweets, [:bag, :private, :named_table])
    ServerFunctions.retweet(@userId, @otherId, @tweet, false)
    assert :ets.lookup(:retweets, @userId) |> Enum.find(false, fn {_, oid, t, _} ->
      oid == @otherId and t == @tweet
    end)
  end
end
