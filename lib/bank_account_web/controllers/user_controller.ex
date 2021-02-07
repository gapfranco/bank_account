defmodule BankAccountWeb.UserController do
  use BankAccountWeb, :controller

  alias BankAccount.Account
  # alias BankAccount.Account.User
  alias BankAccount.Password
  alias BankAccount.AES

  action_fallback BankAccountWeb.FallbackController

  def login(conn, %{"cpf" => cpf, "password" => password} = _params) do
    case Password.token_signin(cpf, password) do
      {:ok, %{token: jwt_token, user: _user}} ->
        conn
        |> render("login.json", token: jwt_token)

      {:error, message} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BankAccountWeb.ErrorView)
        |> render("401.json", message: message)
    end
  end

  def register(conn, params) do
    case Account.create_user(params) do
      {:ok, _user, :referral_code, referral_code} ->
        conn
        |> render("register.json", referral_code: referral_code)

      {:ok, _user, :status, status} ->
        conn
        |> render("register.json", status: status)

      {:status, status} ->
        conn
        |> render("register.json", status: status)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BankAccountWeb.ErrorView)
        |> render("400.json", changeset: changeset)
    end
  end

  def referrals_list(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    if user.referral_code_gen do
      referrals =
        Account.list_referrals(user.referral_code_gen)
        |> Enum.map(fn elem -> %{id: elem.id, name: AES.decrypt(elem.name)} end)

      render(conn, "referrals.json", referrals: referrals)
    else
      render(conn, "referrals_error.json", message: "Account register not completed")
    end
  end
end
