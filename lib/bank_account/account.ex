defmodule BankAccount.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false

  alias BankAccount.Repo
  alias BankAccount.HashField
  alias BankAccount.Randomizer
  alias BankAccount.Account.User

  @doc """
  Returns the list of referred.
  """
  def list_referrals(referral) do
    query =
      from u in "users",
        where: u.referral_code == ^referral,
        select: %{id: u.id, name: u.name}

    Repo.all(query)
  end

  @doc """
  Gets a single user.
  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def create_user(%{"cpf" => cpf} = attrs) do
    cpf_hash = HashField.hash(cpf)

    result =
      case Repo.get_by(User, cpf_hash: cpf_hash) do
        nil ->
          %User{}
          |> User.changeset_with_password(attrs)
          |> Repo.insert()

        user ->
          user
          |> User.changeset(attrs)
          |> Repo.update()
      end

    with {:ok, user} <- result do
      ok =
        user.birth_date && user.city && user.country && user.name && user.gender && user.email &&
          user.password &&
          user.state && user.id

      if ok do
        referral_code = user.referral_code_gen || Randomizer.randomizer(8)

        user
        |> User.referral_changeset(%{"referral_code_gen" => referral_code, "status" => :complete})
        |> Repo.update()

        {:ok, user, :referral_code, referral_code}
      else
        {:ok, user, :status, "pending"}
      end
    else
      {:error, changeset} -> {:error, changeset}
    end
  end

  def create_user(_attrs) do
    {:status, "CPF missing"}
  end
end
