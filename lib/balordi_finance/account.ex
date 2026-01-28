defmodule BalordiFinance.Account do
  @moduledoc """
    Manages the individual account
  """
  use GenServer

  @doc """
    Initializing the server with an initial balance
  """
  def start_link([iban, initial_balance]) do
    GenServer.start_link(__MODULE__, [iban, initial_balance], name: via_tuple(iban))
  end

  @doc """
    Set the initial state (balance) when the server starts up
  """
  @impl true
  def init([iban, initial_balance]) do
    actual_balance = read_from_disk(iban, initial_balance)
    state = %{iban: iban, balance: actual_balance}
    save_to_disk(iban, actual_balance)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_balance, _from, state) do
    {:reply, state.balance, state}
  end

  @impl true
  def handle_call({:withdraw, amount}, _from, state) do
    if state.balance >= amount do
      new_balance = state.balance - amount
      save_to_disk(state.iban, new_balance)
      {:reply, :ok, %{state | balance: new_balance}}
    else
      {:reply, {:error, "Insufficient funds, barbone!"}, state}
    end
  end

  @impl true
  def handle_cast({:deposit, amount}, state) do
    new_balance = state.balance + amount
    save_to_disk(state.iban, new_balance)
    {:noreply, %{state | balance: new_balance}}
  end

  def get_balance(iban) do
    GenServer.call(via_tuple(iban), :get_balance)
  end

  def withdraw(iban, amount) do
    case Registry.lookup(Balordi.Registry, iban) do
      [{_pid, _}] ->
        GenServer.call(via_tuple(iban), {:withdraw, amount})
      [] ->
        {:error, "Account not found"}
    end
  end

  def deposit(iban, amount) do
    GenServer.cast(via_tuple(iban), {:deposit, amount})
  end

  # Create the address in the registry
  # Register the IBAN as a key, useful for finding the process without using the PID
  def via_tuple(iban), do: {:via, Registry, {Balordi.Registry, iban}}

  # Utility for saving data to disk, so that it is not lost in the event of errors
  defp save_to_disk(iban, balance) do
    File.write!(data_path(iban), "#{balance}")
  end

  # Utility for reading data on disk
  defp read_from_disk(iban, default_balance) do
    case File.read(data_path(iban)) do
      {:ok, content} ->
        String.to_integer(content)
      {:error, _} ->
        default_balance
    end
  end

  # If we are in the test environment use 'test_data' folder, otherwise the default 'data' folder
  defp data_path(iban) do
    folder = if Mix.env() == :test, do: "test_data", else: "data"
    File.mkdir_p!(folder)
    "#{folder}/#{iban}.txt"
  end
end
