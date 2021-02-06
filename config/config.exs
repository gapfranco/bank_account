# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bank_account,
  ecto_repos: [BankAccount.Repo]

# Configures the endpoint
config :bank_account, BankAccountWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "91vElhArh3EU3jvFVbTVwfdNw+/NY0GS7lUupn9iict8ENODVyuvi8m7T97QXhmg",
  render_errors: [view: BankAccountWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: BankAccount.PubSub,
  live_view: [signing_salt: "+GV5jARP"]

# Guardian config
config :bank_account, BankAccount.Guardian,
  issuer: "bank_account",
  secret_key: "Bkv4PzvhCk0wpt2QmjJE1pPGSsSkKvazwgEAPWtqxrCe9ZRvOwEOCPsLQ92OOP1w"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
