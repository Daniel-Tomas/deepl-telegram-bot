defmodule DeeplTgBotTest do
  use ExUnit.Case
  doctest DeeplTgBot

  test "greets the world" do
    assert DeeplTgBot.hello() == :world
  end
end
