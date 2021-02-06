defmodule BankAccountWeb.UserView do
  use BankAccountWeb, :view

  def render("sign_on.json", %{referral_code: referral_code}) do
    %{
      message: "Account creation",
      status: :complete,
      referral_code: referral_code
    }
  end

  def render("sign_on.json", %{status: status}) do
    %{
      message: "Account creation",
      status: status
    }
  end

  def render("sign_on.json", %{message: message}) do
    %{
      message: message
    }
  end

  def render("sign_in.json", %{token: jwt_token}) do
    %{token: jwt_token}
  end
end
