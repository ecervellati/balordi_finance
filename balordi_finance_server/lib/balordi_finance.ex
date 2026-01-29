defmodule BalordiFinance do
  @moduledoc """
    Main entry point. Delegates for main operations
  """

  defdelegate transfer(from, to, amount), to: BalordiFinance.Bank
  defdelegate get_balance(iban), to: BalordiFinance.Account
  defdelegate open_account(iban, initial_balance), to: BalordiFinance.AccountSupervisor, as: :start_account

  @doc """
    Utility to check if the system is ready
  """
  def status do
    %{
      registry: Process.whereis(Balordi.Registry) != nil,
      supervisor: Process.whereis(BalordiFinance.AccountSupervisor) != nil,
      uptime: :erlang.statistics(:wall_clock) |> elem(0)
    }
  end
end
