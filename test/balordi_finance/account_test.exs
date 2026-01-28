defmodule BalordiFinance.AccountTest do
  use ExUnit.Case

  setup do
    iban = "ACC_TEST_IBAN_#{:rand.uniform(1000)}"
    {:ok, _pid} = BalordiFinance.AccountSupervisor.start_account(iban, 100)
    %{iban: iban}
  end

  test "The account balance must be correct. Behavior expected: OK", %{iban: iban} do
    assert BalordiFinance.Account.get_balance(iban) == 100
  end

  test "The deposit increases the account balance. Behavior expected: OK", %{iban: iban} do
    BalordiFinance.Account.deposit(iban, 50)
    assert BalordiFinance.Account.get_balance(iban) == 150
  end

  test "The withdrawal reduces the account balance. Behavior expected: OK", %{iban: iban} do
    assert BalordiFinance.Account.withdraw(iban, 30) == :ok
    assert BalordiFinance.Account.get_balance(iban) == 70
  end

  test "The withdrawal fails if there are insufficient funds. Behavior expected: FAIL", %{iban: iban} do
    assert {:error, _reason} = BalordiFinance.Account.withdraw(iban, 500)
    assert BalordiFinance.Account.get_balance(iban) == 100
  end
end
