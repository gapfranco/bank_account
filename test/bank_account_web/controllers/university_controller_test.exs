defmodule BankAccountWeb.UniversityControllerTest do
  use BankAccountWeb.ConnCase

  alias BankAccount.Teach
  alias BankAccount.Teach.University
  alias BankAccount.Guardian

  @create_attrs %{
    logo_url: "some logo_url",
    name: "some name",
    score: 120.5
  }
  @update_attrs %{
    logo_url: "some updated logo_url",
    name: "some updated name",
    score: 456.7
  }
  @invalid_attrs %{logo_url: nil, name: nil, score: nil}

  @user %{id: 1, email: "usr@cl1.com"}

  def fixture(:university) do
    {:ok, university} = Teach.create_university(@create_attrs)
    university
  end

  setup %{conn: conn} do
    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> conn_token()

    {:ok, conn: conn}
  end

  def conn_token(conn) do
    {:ok, token, _} = Guardian.encode_and_sign(@user)
    conn |> put_req_header("authorization", "Bearer #{token}")
  end

  describe "index" do
    test "lists all universities", %{conn: conn} do
      conn = get(conn, Routes.university_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create university" do
    test "renders university when data is valid", %{conn: conn} do
      conn = post(conn, Routes.university_path(conn, :create), university: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.university_path(conn, :show, id))

      assert %{
               "id" => _id,
               "logo_url" => "some logo_url",
               "name" => "some name",
               "score" => 120.5
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.university_path(conn, :create), university: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update university" do
    setup [:create_university]

    test "renders university when data is valid", %{
      conn: conn,
      university: %University{id: id} = university
    } do
      conn =
        put(conn, Routes.university_path(conn, :update, university), university: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.university_path(conn, :show, id))

      assert %{
               "id" => _id,
               "logo_url" => "some updated logo_url",
               "name" => "some updated name",
               "score" => 456.7
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, university: university} do
      conn =
        put(conn, Routes.university_path(conn, :update, university), university: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete university" do
    setup [:create_university]

    test "deletes chosen university", %{conn: conn, university: university} do
      conn = delete(conn, Routes.university_path(conn, :delete, university))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.university_path(conn, :show, university))
      end
    end
  end

  defp create_university(_) do
    university = fixture(:university)
    %{university: university}
  end
end
