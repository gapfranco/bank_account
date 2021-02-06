defmodule BankAccountWeb.CampusControllerTest do
  use BankAccountWeb.ConnCase

  alias BankAccount.Teach
  alias BankAccount.Teach.Campus
  alias BankAccount.Guardian

  @university_attrs %{
    name: "Uniteste",
    score: 90.2,
    logo_url: "url"
  }

  @create_attrs %{
    city: "some city",
    name: "some name"
  }
  @update_attrs %{
    city: "some updated city",
    name: "some updated name"
  }
  @invalid_attrs %{city: nil, name: nil}

  @user %{id: 1, email: "usr@cl1.com"}

  # def fixture(:campus) do
  #   {:ok, campus} = Teach.create_campus(@create_attrs)
  #   campus
  # end

  def fixture(:university) do
    {:ok, university} = Teach.create_university(@university_attrs)
    university
  end

  def fixture(:campus, university_id) do
    {:ok, campus} =
      %{university_id: university_id}
      |> Enum.into(@create_attrs)
      |> Teach.create_campus()

    campus
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
    test "lists all campus", %{conn: conn} do
      conn = get(conn, Routes.campus_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create campus" do
    # test "renders campus when data is valid", %{conn: conn} do
    #   conn = post(conn, Routes.campus_path(conn, :create), campus: @create_attrs)
    #   assert %{"id" => id} = json_response(conn, 201)["data"]

    #   # conn = get(conn, Routes.campus_path(conn, :show, id))

    #   # assert %{
    #   #          "id" => id,
    #   #          "city" => "some city",
    #   #          "name" => "some name"
    #   #        } = json_response(conn, 200)["data"]
    # end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.campus_path(conn, :create), campus: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update campus" do
    setup [:create_campus]

    test "renders campus when data is valid", %{conn: conn, campus: %Campus{id: id} = campus} do
      conn = put(conn, Routes.campus_path(conn, :update, campus), campus: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      # conn = get(conn, Routes.campus_path(conn, :show, id))

      # assert %{
      #          "id" => id,
      #          "city" => "some updated city",
      #          "name" => "some updated name"
      #        } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, campus: campus} do
      conn = put(conn, Routes.campus_path(conn, :update, campus), campus: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete campus" do
    setup [:create_campus]

    test "deletes chosen campus", %{conn: conn, campus: campus} do
      conn = delete(conn, Routes.campus_path(conn, :delete, campus))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.campus_path(conn, :show, campus))
      end
    end
  end

  defp create_campus(_) do
    university = fixture(:university)
    campus = fixture(:campus, university.id)
    %{campus: campus}
  end
end
