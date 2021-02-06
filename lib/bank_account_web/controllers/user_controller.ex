defmodule BankAccountWeb.UserController do
  use BankAccountWeb, :controller

  alias BankAccount.Account
  # alias BankAccount.Account.User
  alias BankAccount.Password

  action_fallback BankAccountWeb.FallbackController

  def sign_in(conn, %{"cpf" => cpf, "password" => password} = _params) do
    case Password.token_signin(cpf, password) do
      {:ok, %{token: jwt_token, user: _user}} ->
        conn
        |> render("sign_in.json", token: jwt_token)

      {:error, message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BankAccountWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end

  def sign_on(conn, params) do
    case Account.create_user(params) do
      {:referral_code, referral_code} ->
        conn
        |> render("sign_on.json", referral_code: referral_code)

      {:status, status} ->
        conn
        |> render("sign_on.json", status: status)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BankAccountWeb.ErrorView)
        |> render("400.json", changeset: changeset)

        # {:error, message} ->
        #   conn
        #   |> render("sign_on.json", message: message)
    end
  end
end
