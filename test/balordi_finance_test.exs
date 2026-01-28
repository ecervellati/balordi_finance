defmodule BalordiFinanceTest do
  use ExUnit.Case
  doctest BalordiFinance

  setup do
    iban_a = "BF_TEST_A_#{:rand.uniform(1000)}"
    iban_b = "BF_TEST_B_#{:rand.uniform(1000)}"

    BalordiFinance.open_account(iban_a, 100)
    BalordiFinance.open_account(iban_b, 50)

    on_exit(fn ->
      File.rm_rf!("test_data")
    end)

    %{iban_a: iban_a, iban_b: iban_b}
  end

  test "Get account balance. Behavior expected: OK", %{iban_a: iban_a} do
    assert BalordiFinance.get_balance(iban_a) == 100
  end

  test "Transfer between accounts. Behavior expected: OK", %{iban_a: iban_a, iban_b: iban_b} do
    assert :ok == BalordiFinance.transfer(iban_a, iban_b, 30)
    assert BalordiFinance.get_balance(iban_a) == 70
    assert BalordiFinance.get_balance(iban_b) == 80
  end

  test "Status of the server. Behavior expected: OK" do
    status = BalordiFinance.status()
    assert status.registry == true
    assert status.supervisor == true
    assert is_integer(status.uptime)
  end
end
