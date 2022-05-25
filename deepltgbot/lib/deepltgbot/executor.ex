defmodule Deepltgbot.Executor do
  alias Deepltgbot.Bot

  def child_spec([msg, context]) do
    %{
      id: "id",
      start: {__MODULE__, :start_link, [msg, context]},
      restart: :transient
    }
  end

  def start_link(msg, context) do
    Bot.async_translate(msg, context)
  end
end
