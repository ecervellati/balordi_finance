defmodule BalordiFinance.AccountSupervisor do
  @moduledoc """
    Create and restart accounts dynamically
  """
  use DynamicSupervisor

  @doc """
    Set the initial status (balance) when the server starts up.
    __MODULE__ -> BalordiFinance.AccountSupervisor
    The name must always be included in the options (usually the last argument of the start_link function).
  """
  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc """
    It creates a new account
  """
  def start_account(iban, initial_balance) do
    spec = {BalordiFinance.Account, [iban, initial_balance]}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc """
    Strategy: one_for_one. If a child dies, only restart that child.
  """
  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
