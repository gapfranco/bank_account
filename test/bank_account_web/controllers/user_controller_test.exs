defmodule BankAccountWeb.UserControllerTest do
  use BankAccountWeb.ConnCase

  alias BankAccount.Account

  @complete_attrs %{
    "cpf" => "465.876.620-56",
    "email" => "valid@email",
    "password" => "123123",
    "name" => "A name",
    "birth_date" => "1959-02-11",
    "gender" => "male",
    "city" => "A city",
    "state" => "UF",
    "country" => "Brasil"
  }

  @partial_attrs %{
    "cpf" => "465.876.620-56",
    "password" => "123123"
  }

  @login_attrs %{
    "cpf" => "465.876.620-56",
    "password" => "123123"
  }

  def fixture(:user) do
    {:ok, user, _, _} = Account.create_user(@complete_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "login" do
    setup [:create_user]

    test "user can login", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), @login_attrs)

      assert %{
               "token" => _token
             } = json_response(conn, 200)
    end
  end

  describe "register" do
    test "user can register partially", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :register), @partial_attrs)

      assert %{
               "message" => "Account creation",
               "status" => "pending"
             } = json_response(conn, 200)
    end

    test "user can register completely", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :register), @complete_attrs)

      assert %{
               "message" => "Account creation",
               "status" => "complete"
             } = json_response(conn, 200)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
