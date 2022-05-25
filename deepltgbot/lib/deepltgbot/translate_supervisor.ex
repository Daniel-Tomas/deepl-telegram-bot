defmodule Deepltgbot.TranslateSupervisor do
  use Supervisor

  alias Deepltgbot.Executor

  def start_link([msg, context]) do
    Supervisor.start_link(__MODULE__, [msg, context], name: __MODULE__)
  end

  def init(args) do
    [msg, context] = args
    children = [{Executor, [msg, context]}]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
