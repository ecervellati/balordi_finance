# BalordiFinance Backend

Bank transaction management system based on Elixir and OTP. The project uses isolated processes for each account, so as to be tolerant to failures and concurrency.

## Architecture
- **GenServer (Account)**: Manages the status of individual accounts (balance, IBAN) and persistence on disk with a txt file for each account.
- **Registry**: Process registry system for IBAN addressing.
- **DynamicSupervisor**: Account process manager that ensures restart in case of crash.
- **Plug/Cowboy**: HTTP server for exposing REST APIs.

## Prerequisites
- Elixir 1.15 or higher
- Erlang/OTP 26 or higher

## Installation
1. Clone the repository
2. Install dependencies:
  ```bash
  mix deps.get
  ```
3. Create the folder for data persistence:
  ```bash
  mkdir data
  ```

## Execution
To start the application, run the following command:
```bash
iex -S mix
```

## API Endpoints
### POST/transfer
Allows you to make a transfer between two existing accounts.
#### Payload JSON:
```json
{
  "from": "IBAN_MITTENTE",
  "to": "IBAN_RICEVENTE",
  "amount": 100
}
```

#### Responses:
- 200 OK: Transfer completed.
- 400 Bad Request: Insufficient funds or incorrect parameters. This response includes an insult: balordo. 
