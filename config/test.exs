use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :bank_account, BankAccount.Repo,
  username: "postgres",
  password: "postgres",
  database: "bank_account_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bank_account, BankAccountWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :bank_account, BankAccount.AES,
  keys: [
    :base64.decode("vA/K/7K6Z3obnTxlPx6fDuy/tiPj4FS7dDtUpfvRbG4=")
  ]
