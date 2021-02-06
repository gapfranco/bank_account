defmodule BankAccount.TeachTest do
  use BankAccount.DataCase

  alias BankAccount.Teach

  describe "universities" do
    alias BankAccount.Teach.University

    @valid_attrs %{logo_url: "some logo_url", name: "some name", score: 120.5}
    @update_attrs %{logo_url: "some updated logo_url", name: "some updated name", score: 456.7}
    @invalid_attrs %{logo_url: nil, name: nil, score: nil}

    def university_fixture(attrs \\ %{}) do
      {:ok, university} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Teach.create_university()

      university
    end

    test "list_universities/0 returns all universities" do
      university = university_fixture()
      assert Teach.list_universities() == [university]
    end

    test "get_university!/1 returns the university with given id" do
      university = university_fixture()
      assert Teach.get_university!(university.id) == university
    end

    test "create_university/1 with valid data creates a university" do
      assert {:ok, %University{} = university} = Teach.create_university(@valid_attrs)
      assert university.logo_url == "some logo_url"
      assert university.name == "some name"
      assert university.score == 120.5
    end

    test "create_university/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teach.create_university(@invalid_attrs)
    end

    test "update_university/2 with valid data updates the university" do
      university = university_fixture()

      assert {:ok, %University{} = university} =
               Teach.update_university(university, @update_attrs)

      assert university.logo_url == "some updated logo_url"
      assert university.name == "some updated name"
      assert university.score == 456.7
    end

    test "update_university/2 with invalid data returns error changeset" do
      university = university_fixture()
      assert {:error, %Ecto.Changeset{}} = Teach.update_university(university, @invalid_attrs)
      assert university == Teach.get_university!(university.id)
    end

    test "delete_university/1 deletes the university" do
      university = university_fixture()
      assert {:ok, %University{}} = Teach.delete_university(university)
      assert_raise Ecto.NoResultsError, fn -> Teach.get_university!(university.id) end
    end

    test "change_university/1 returns a university changeset" do
      university = university_fixture()
      assert %Ecto.Changeset{} = Teach.change_university(university)
    end
  end

  describe "campus" do
    alias BankAccount.Teach.Campus

    @valid_attrs %{city: "some city", name: "some name"}
    @update_attrs %{city: "some updated city", name: "some updated name"}
    @invalid_attrs %{city: nil, name: nil}

    def campus_fixture(attrs \\ %{}) do
      university = university_fixture()

      {:ok, campus} =
        %{university_id: university.id}
        |> Enum.into(attrs)
        |> Enum.into(@valid_attrs)
        |> Teach.create_campus()

      campus
    end

    test "list_campus/0 returns all campus" do
      campus = campus_fixture()
      assert Teach.list_campus() == [campus]
    end

    test "get_campus!/1 returns the campus with given id" do
      campus = campus_fixture()
      assert Teach.get_campus!(campus.id) == campus
    end

    test "create_campus/1 with valid data creates a campus" do
      campus = campus_fixture()
      assert campus.city == "some city"
      assert campus.name == "some name"
    end

    test "create_campus/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teach.create_campus(@invalid_attrs)
    end

    test "update_campus/2 with valid data updates the campus" do
      campus = campus_fixture()
      assert {:ok, %Campus{} = campus} = Teach.update_campus(campus, @update_attrs)
      assert campus.city == "some updated city"
      assert campus.name == "some updated name"
    end

    test "update_campus/2 with invalid data returns error changeset" do
      campus = campus_fixture()
      assert {:error, %Ecto.Changeset{}} = Teach.update_campus(campus, @invalid_attrs)
      assert campus == Teach.get_campus!(campus.id)
    end

    test "delete_campus/1 deletes the campus" do
      campus = campus_fixture()
      assert {:ok, %Campus{}} = Teach.delete_campus(campus)
      assert_raise Ecto.NoResultsError, fn -> Teach.get_campus!(campus.id) end
    end
  end

  describe "courses" do
    alias BankAccount.Teach.Course

    @valid_attrs %{kind: "Presencial", level: "Bacharelado", name: "some name", shift: "Noite"}
    @update_attrs %{
      kind: "EaD",
      level: "Tecnólogo",
      name: "some updated name",
      shift: "Manhã"
    }
    @invalid_attrs %{kind: nil, level: nil, name: nil, shift: nil}

    def course_fixture(attrs \\ %{}) do
      campus = campus_fixture()

      {:ok, course} =
        %{campus_id: campus.id}
        |> Enum.into(attrs)
        |> Enum.into(@valid_attrs)
        |> Teach.create_course()

      course
    end

    test "list_courses/0 returns all courses" do
      course = course_fixture()
      [curso1] = Teach.list_courses()
      assert curso1.id == course.id
      assert curso1.university_id == course.university_id
      assert curso1.campus_id == course.campus_id
    end

    test "get_course!/1 returns the course with given id" do
      course = course_fixture()
      assert Teach.get_course!(course.id) == course
    end

    test "create_course/1 with valid data creates a course" do
      course = course_fixture()
      assert course.kind == "Presencial"
      assert course.level == "Bacharelado"
      assert course.name == "some name"
      assert course.shift == "Noite"
    end

    test "create_course/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teach.create_course(@invalid_attrs)
    end

    test "update_course/2 with valid data updates the course" do
      course = course_fixture()
      assert {:ok, %Course{} = course} = Teach.update_course(course, @update_attrs)
      assert course.kind == "EaD"
      assert course.level == "Tecnólogo"
      assert course.name == "some updated name"
      assert course.shift == "Manhã"
    end

    test "update_course/2 with invalid data returns error changeset" do
      course = course_fixture()
      assert {:error, %Ecto.Changeset{}} = Teach.update_course(course, @invalid_attrs)
      assert course == Teach.get_course!(course.id)
    end

    test "delete_course/1 deletes the course" do
      course = course_fixture()
      assert {:ok, %Course{}} = Teach.delete_course(course)
      assert_raise Ecto.NoResultsError, fn -> Teach.get_course!(course.id) end
    end
  end

  describe "bids" do
    alias BankAccount.Teach.Bid

    @valid_attrs %{
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

    def bid_fixture(attrs \\ %{}) do
      course = course_fixture()

      {:ok, bid} =
        %{course_id: course.id}
        |> Enum.into(attrs)
        |> Enum.into(@valid_attrs)
        |> Teach.create_bid()

      bid
    end

    test "list_bids/0 returns all bids" do
      bid = bid_fixture()
      [bid1] = Teach.list_bids()
      assert bid1.id == bid.id
      assert bid1.course_id == bid.course_id
      assert bid1.university_id == bid.university_id
      assert bid1.campus_id == bid.campus_id
    end

    test "get_bid!/1 returns the bid with given id" do
      bid = bid_fixture()
      assert Teach.get_bid!(bid.id) == bid
    end

    test "create_bid/1 with valid data creates a bid" do
      # assert {:ok, %Bid{} = bid} = Teach.create_bid(@valid_attrs)
      bid = bid_fixture()
      assert bid.discount_percentage == 120.5
      assert bid.enabled == true
      assert bid.enrollment_semester == "some enrollment_semester"
      assert bid.full_price == 120.5
      assert bid.price_with_discount == 120.5
      assert bid.start_date == "some start_date"
    end

    test "create_bid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teach.create_bid(@invalid_attrs)
    end

    test "update_bid/2 with valid data updates the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{} = bid} = Teach.update_bid(bid, @update_attrs)
      assert bid.discount_percentage == 456.7
      assert bid.enabled == false
      assert bid.enrollment_semester == "some updated enrollment_semester"
      assert bid.full_price == 456.7
      assert bid.price_with_discount == 456.7
      assert bid.start_date == "some updated start_date"
    end

    test "update_bid/2 with invalid data returns error changeset" do
      bid = bid_fixture()
      assert {:error, %Ecto.Changeset{}} = Teach.update_bid(bid, @invalid_attrs)
      assert bid == Teach.get_bid!(bid.id)
    end

    test "delete_bid/1 deletes the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{}} = Teach.delete_bid(bid)
      assert_raise Ecto.NoResultsError, fn -> Teach.get_bid!(bid.id) end
    end

    test "change_bid/1 returns a bid changeset" do
      bid = bid_fixture()
      assert %Ecto.Changeset{} = Teach.change_bid(bid)
    end
  end
end
