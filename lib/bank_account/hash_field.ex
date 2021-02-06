defmodule BankAccount.HashField do
  def hash(value) do
    :crypto.hash(:sha256, value <> get_salt(value))
  end

  # Get/use Phoenix secret_key_base as "salt" for one-way hashing Email address
  # use the *value* to create a *unique* "salt" for each value that is hashed:
  defp get_salt(value) do
    secret_key_base =
      Application.get_env(:bank_account, BankAccountWeb.Endpoint)[:secret_key_base]

    :crypto.hash(:sha256, value <> secret_key_base)
  end
end
