defmodule BankAccount.Password do
  import Pbkdf2

  alias BankAccount.Guardian
  alias BankAccount.Account.User
  alias BankAccount.Repo
  alias BankAccount.HashField

  def hash(password) do
    hash_pwd_salt(password)
  end

  def verify_with_hash(password, hash), do: verify_pass(password, hash)

  def dummy_verify, do: no_user_verify()

  def token_signin(cpf, password) do
    with {:ok, user} <- uid_password_auth(cpf, password),
         {:ok, jwt_token, _} <- Guardian.encode_and_sign(user) do
      {:ok, %{token: jwt_token, user: user}}
    end
  end

  defp uid_password_auth(cpf, password) when is_binary(cpf) and is_binary(password) do
    with {:ok, user} <- get_by_cpf(cpf),
         do: verify_password(password, user)
  end

  defp get_by_cpf(cpf) when is_binary(cpf) do
    cpf_hash = HashField.hash(cpf)

    case Repo.get_by(User, cpf_hash: cpf_hash) do
      nil ->
        dummy_verify()
        {:error, :login_error}

      user ->
        {:ok, user}
    end
  end

  def verify_password(password, %User{} = user) when is_binary(password) do
    if verify_with_hash(password, user.password) do
      {:ok, user}
    else
      {:error, :login_error}
    end
  end
end
