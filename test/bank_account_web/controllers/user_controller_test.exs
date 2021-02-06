defmodule BankAccountWeb.UserControllerTest do
  use BankAccountWeb.ConnCase

  alias BankAccount.Account

  @create_attrs %{
    email: "some@email.com",
    password: "some password"
  }

  def fixture(:user) do
    {:ok, user} = Account.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "sign_in" do
    setup [:create_user]

    test "user can sign in", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :sign_in), @create_attrs)

      assert %{
               "token" => _token
             } = json_response(conn, 200)
    end
  end

  describe "sign_on" do
    test "user can sign on", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :sign_on), @create_attrs)

      assert %{
               "email" => "some@email.com"
             } = json_response(conn, 200)["user"]
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
