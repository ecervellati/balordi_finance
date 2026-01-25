defmodule BalordiFinance.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Search the environment variable 'PORT'
    port = String.to_integer(System.get_env("PORT") || "4005")
    children = [
      {Registry, keys: :unique, name: Balordi.Registry},
      BalordiFinance.AccountSupervisor,
      {Plug.Cowboy, scheme: :http, plug: BalordiFinance.Router, options: [port: port]}
    ]

    opts = [strategy: :one_for_one, name: BalordiFinance.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
