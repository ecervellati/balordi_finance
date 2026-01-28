defmodule BalordiFinance.BankTest do
  use ExUnit.Case

  setup do
    iban_a = "BANK_TEST_A_#{:rand.uniform(1000)}"
    iban_b = "BANK_TEST_B_#{:rand.uniform(1000)}"

    BalordiFinance.AccountSupervisor.start_account(iban_a, 100)
    BalordiFinance.AccountSupervisor.start_account(iban_b, 50)

    on_exit(fn -> File.rm_rf!("test_data") end)

    %{a: iban_a, b: iban_b}
  end

  test "Successful transfer between two accounts. Behavior expected: OK", %{a: a, b: b} do
    assert :ok == BalordiFinance.Bank.transfer(a, b, 40)
    assert BalordiFinance.Account.get_balance(a) == 60
    assert BalordiFinance.Account.get_balance(b) == 90
  end

  test "Transfer fails due to insufficient funds. Behavior expected: FAIL", %{a: a, b: b} do
    assert {:error, "Insufficient funds, barbone!"} == BalordiFinance.Bank.transfer(a, b, 500)
    assert BalordiFinance.Account.get_balance(a) == 100
    assert BalordiFinance.Account.get_balance(b) == 50
  end

  test "Transfer fails if an account does not exist. Behavior expected: FAIL", %{a: a} do
    assert {:error, "One of the accounts does not exist!"} == BalordiFinance.Bank.transfer(a, "NON_ESISTO", 10)
    assert BalordiFinance.Account.get_balance(a) == 100
  end
end
