defmodule DeeplTgBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      ExGram,
      {DeeplTgBot.Bot, [method: :polling, token: System.get_env("BOT_TOKEN")]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DeeplTgBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
