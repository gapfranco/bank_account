defmodule BankAccountWeb.UserView do
  use BankAccountWeb, :view

  def render("register.json", %{referral_code: referral_code}) do
    %{
      message: "Account creation",
      status: :complete,
      referral_code: referral_code
    }
  end

  def render("register.json", %{status: status}) do
    %{
      message: "Account creation",
      status: status
    }
  end

  def render("register.json", %{message: message}) do
    %{
      message: message
    }
  end

  def render("login.json", %{token: jwt_token}) do
    %{
      message: "Connected",
      token: jwt_token
    }
  end

  def render("referrals.json", %{referrals: referrals}) do
    %{data: render_many(referrals, BankAccountWeb.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name
    }
  end

  def render("referrals_error.json", %{message: message}) do
    %{
      message: message
    }
  end
end
