defmodule BankAccountWeb.CourseControllerTest do
  use BankAccountWeb.ConnCase

  alias BankAccount.Teach
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

  @create_attrs %{
    kind: "Presencial",
    level: "Bacharelado",
    name: "some name",
    shift: "Noite"
  }
  @update_attrs %{
    kind: "EaD",
    level: "Tecnólogo",
    name: "some updated name",
    shift: "Manhã"
  }
  @invalid_attrs %{kind: nil, level: nil, name: nil, shift: nil}

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
      |> Enum.into(@create_attrs)
      |> Teach.create_course()

    course
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
    test "lists all courses", %{conn: conn} do
      conn = get(conn, Routes.course_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create course" do
    setup [:create_campus]

    test "renders course when data is valid", %{conn: conn, campus: campus} do
      create_attrs =
        %{campus_id: campus.id}
        |> Enum.into(@create_attrs)

      conn = post(conn, Routes.course_path(conn, :create), course: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.course_path(conn, :show, id))

      assert %{
               "id" => _id,
               "kind" => "Presencial",
               "level" => "Bacharelado",
               "name" => "some name",
               "shift" => "Noite"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.course_path(conn, :create), course: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update course" do
    setup [:create_course]

    test "renders course when data is valid", %{
      conn: conn,
      course: %Course{id: id} = course
    } do
      conn = put(conn, Routes.course_path(conn, :update, course), course: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.course_path(conn, :show, id))

      assert %{
               "id" => _id,
               "kind" => "EaD",
               "level" => "Tecnólogo",
               "name" => "some updated name",
               "shift" => "Manhã"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, course: course} do
      conn = put(conn, Routes.course_path(conn, :update, course), course: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete course" do
    setup [:create_course]

    test "deletes chosen course", %{conn: conn, course: course} do
      conn = delete(conn, Routes.course_path(conn, :delete, course))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.course_path(conn, :show, course))
      end
    end
  end

  defp create_course(_) do
    university = fixture(:university)
    campus = fixture(:campus, university.id)
    course = fixture(:course, campus.id)
    %{course: course}
  end

  defp create_campus(_) do
    university = fixture(:university)
    campus = fixture(:campus, university.id)
    %{campus: campus}
  end
end
