defmodule BalordiFinance.Bank do
  @moduledoc """
    Functions for calculations
  """
  alias BalordiFinance.Account

  def transfer(from_iban, to_iban, amount) do
    case Account.withdraw(from_iban, amount) do
      :ok ->
        Account.deposit(to_iban, amount)
        IO.puts("Transfer of #{amount}€ from #{from_iban} to #{to_iban} completed!")
        :ok

      {:error, "Account not found"} ->
        {:error, "One of the accounts does not exist!"}

      {:error, reason} ->
        IO.puts("Error: #{reason}")
        {:error, reason}
    end
  end
end
