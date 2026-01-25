defmodule BalordiFinance.Router do
  @moduledoc """
    API Management
  """
  use Plug.Router

  # Pipeline
  plug :match
  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  plug :dispatch

  # Endpoint for transfer
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

  match _ do
    send_resp(conn, 404, "There's nothing here, balordo!")
  end
end
