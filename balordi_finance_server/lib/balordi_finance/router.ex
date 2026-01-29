defmodule BalordiFinance.Router do
  @moduledoc """
    API Management
  """
  use Plug.Router

  # Pipeline
  plug CORSPlug, origin: "*"
  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  plug :dispatch

  get "/accounts" do
    accounts =
      Registry.select(Balordi.Registry, [{{:"$1", :"$2", :"$3"}, [], [{{:"$1", :"$2", :"$3"}}]}])
      |> Enum.map(fn {iban, _pid, _value} ->
           balance = case BalordiFinance.get_balance(iban) do
            {:ok, val} -> val
            val when is_integer(val) -> val
            _ -> 0
           end
           %{iban: iban, amount: balance}
         end)

    send_resp(conn, 200, Jason.encode!(accounts))
  end

  post "/transfer" do
    IO.inspect(conn.body_params, label: "INPUT PARAMTERS")
    case conn.body_params do
      %{"from" => from, "to" => to, "amount" => amount} ->
      case BalordiFinance.Bank.transfer(from, to, amount) do
        :ok ->
          send_resp(conn, 200, Jason.encode!(%{status: "success", message: "Transfer completed!"}))
        {:error, reason} ->
          send_resp(conn, 400, Jason.encode!(%{status: "error", message: reason}))
      end
      _ ->
      send_resp(conn, 400, "Missing data, balordo!")
    end
  end

  post "/accounts" do
    iban = conn.body_params["iban"]
    balance =
      case conn.body_params["amount"] do
        b when is_binary(b) -> String.to_integer(b)
        b when is_integer(b) -> b
        _ -> 0
      end

    BalordiFinance.open_account(iban, balance)
    send_resp(conn, 201, Jason.encode!(%{status: "Created", iban: iban}))
  end

  match _ do
    send_resp(conn, 404, "There's nothing here, balordo!")
  end
end
