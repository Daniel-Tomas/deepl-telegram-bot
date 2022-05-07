defmodule Deepltgbot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # This will setup the Registry.ExGram
      ExGram,
      {Deepltgbot.Bot,
       [method: :polling, token: "5394215074:AAGmlaQAYsQtAFkyinh3h211VTOzOjFykQo"]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Deepltgbot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
