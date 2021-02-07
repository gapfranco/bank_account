defmodule BankAccount.AccountTest do
  use BankAccount.DataCase

  alias BankAccount.Account
  alias BankAccount.Account.User
  alias BankAccount.AES
  alias BankAccount.HashField

  describe "register account" do
    @pending_attrs %{
      "cpf" => "465.876.620-56",
      "password" => "123123",
      "name" => "A name"
    }
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
    @invalid_attrs %{
      "cpf" => "465.876.620-56",
      "password" => "123123",
      "birth_date" => "erro",
      "gender" => "erro"
    }

    test "create_user/1 with incomplete data creates a user with pending status" do
      assert {:ok, _, :status, "pending"} = Account.create_user(@pending_attrs)
    end

    test "create_user/1 with complete data creates a user with complete status" do
      assert {:ok, _, :referral_code, _referral_code} = Account.create_user(@complete_attrs)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Account.create_user(@invalid_attrs)
    end
  end

  describe "Verify correct working of encryption and hashing" do
    setup do
      Account.create_user(@complete_attrs)
      :ok
    end

    test "can decrypt values of encrypted fields when loaded from database" do
      found_user = Repo.one(User)
      assert AES.decrypt(found_user.name) == "A name"
      assert AES.decrypt(found_user.email) == "valid@email"
      assert AES.decrypt(found_user.cpf) == "465.876.620-56"
      assert AES.decrypt(found_user.birth_date) == "1959-02-11"
    end

    test "can get value of cpf_hash field when loaded from database" do
      found_user = Repo.one(User)
      assert found_user.cpf_hash == HashField.hash("465.876.620-56")
    end
  end

  describe "Verify correct working of referral codes query" do
    setup do
      {:ok, _, :referral_code, referral_code} = Account.create_user(@complete_attrs)

      # account without the referral code
      attrs1 =
        Map.put(@complete_attrs, "cpf", "882.401.635-99")
        |> Map.put("name", "name1")

      # account with the referral code
      attrs2 =
        Map.put(@complete_attrs, "cpf", "197.583.853-05")
        |> Map.put("name", "name2")
        |> Map.put("referral_code", referral_code)

      Account.create_user(attrs1)
      Account.create_user(attrs2)
      {:ok, referral_code: referral_code}
    end

    test "can get correct list of referred users", %{referral_code: referral_code} do
      referrals =
        Account.list_referrals(referral_code)
        |> Enum.map(fn elem -> %{id: elem.id, name: AES.decrypt(elem.name)} end)

      # only "name2" in results
      assert [%{id: _id, name: "name2"}] = referrals
    end
  end
end
