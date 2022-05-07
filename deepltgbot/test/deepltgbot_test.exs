defmodule DeepltgbotTest do
  use ExUnit.Case
  doctest Deepltgbot

  test "greets the world" do
    assert Deepltgbot.hello() == :world
  end
end
