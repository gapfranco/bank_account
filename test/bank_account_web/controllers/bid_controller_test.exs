defmodule BankAccountWeb.BidControllerTest do
  use BankAccountWeb.ConnCase

  alias BankAccount.Teach
  alias BankAccount.Teach.Bid
  alias BankAccount.Teach.Course
  alias BankAccount.Guardian

  @university_attrs %{
    name: "Uniteste",
    score: 90.2,
    logo_url: "url"
  }

  @campus_attrs %{
    name: "Campus",
    city: "Ribeirão"
  }

  @course_attrs %{
    name: "Jornalismo",
    kind: "Presencial",
    level: "Bacharelado",
    shift: "Noite"
  }

  @create_attrs %{
    discount_percentage: 120.5,
    enabled: true,
    enrollment_semester: "some enrollment_semester",
    full_price: 120.5,
    price_with_discount: 120.5,
    start_date: "some start_date"
  }
  @update_attrs %{
    discount_percentage: 456.7,
    enabled: false,
    enrollment_semester: "some updated enrollment_semester",
    full_price: 456.7,
    price_with_discount: 456.7,
    start_date: "some updated start_date"
  }
  @invalid_attrs %{
    discount_percentage: nil,
    enabled: nil,
    enrollment_semester: nil,
    full_price: nil,
    price_with_discount: nil,
    start_date: nil
  }

  @user %{id: 1, email: "usr@cl1.com"}

  def fixture(:university) do
    {:ok, university} = Teach.create_university(@university_attrs)
    university
  end

  def fixture(:campus, university_id) do
    {:ok, campus} =
      %{university_id: university_id}
      |> Enum.into(@campus_attrs)
      |> Teach.create_campus()

    campus
  end

  def fixture(:course, campus_id) do
    {:ok, course} =
      %{campus_id: campus_id}
      |> Enum.into(@course_attrs)
      |> Teach.create_course()

    course
  end

  def fixture(:bid, course_id) do
    {:ok, bid} =
      %{course_id: course_id}
      |> Enum.into(@create_attrs)
      |> Teach.create_bid()

    bid
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
    test "lists all bids", %{conn: conn} do
      conn = get(conn, Routes.bid_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create bid" do
    setup [:create_course]

    test "renders bid when data is valid", %{conn: conn, course: %Course{} = course} do
      create_attrs = %{course_id: course.id} |> Enum.into(@create_attrs)
      conn = post(conn, Routes.bid_path(conn, :create), bid: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.bid_path(conn, :show, id))

      assert %{
               "id" => _id,
               "discount_percentage" => 120.5,
               "enabled" => true,
               "enrollment_semester" => "some enrollment_semester",
               "full_price" => 120.5,
               "price_with_discount" => 120.5,
               "start_date" => "some start_date"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.bid_path(conn, :create), bid: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update bid" do
    setup [:create_bid]

    test "renders bid when data is valid", %{conn: conn, bid: %Bid{id: id} = bid} do
      conn = put(conn, Routes.bid_path(conn, :update, bid), bid: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.bid_path(conn, :show, id))

      assert %{
               "id" => _id,
               "discount_percentage" => 456.7,
               "enabled" => false,
               "enrollment_semester" => "some updated enrollment_semester",
               "full_price" => 456.7,
               "price_with_discount" => 456.7,
               "start_date" => "some updated start_date"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, bid: bid} do
      conn = put(conn, Routes.bid_path(conn, :update, bid), bid: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete bid" do
    setup [:create_bid]

    test "deletes chosen bid", %{conn: conn, bid: bid} do
      conn = delete(conn, Routes.bid_path(conn, :delete, bid))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.bid_path(conn, :show, bid))
      end
    end
  end

  defp create_bid(_) do
    university = fixture(:university)
    campus = fixture(:campus, university.id)
    course = fixture(:course, campus.id)
    bid = fixture(:bid, course.id)
    %{bid: bid}
  end

  defp create_course(_) do
    university = fixture(:university)
    campus = fixture(:campus, university.id)
    course = fixture(:course, campus.id)
    %{course: course}
  end
end
