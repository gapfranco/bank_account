defmodule BankAccount.Account.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankAccount.Password
  import EctoEnum
  alias BankAccount.AES
  alias BankAccount.HashField

  defenum(GenderEnum, :gender, [
    :female,
    :male
  ])

  defenum(StatusEnum, :status, [
    :pending,
    :complete
  ])

  schema "users" do
    field :cpf, :binary
    field :cpf_hash, :binary
    field :email, :binary
    field :name, :binary
    field :birth_date, :binary
    field :gender, GenderEnum
    field :city, :string
    field :state, :string
    field :country, :string
    field :referral_code, :string
    field :referral_code_gen, :string
    field :status, StatusEnum
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :name,
      :birth_date,
      :gender,
      :city,
      :state,
      :country,
      :password,
      :referral_code
    ])
    |> validate_required([:cpf])
    |> validate_date(:birth_date)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "Invalid e-mail")
    |> hash_password()
    |> encrypt_email()
    |> encrypt_name()
    |> encrypt_birth_date()
  end

  @doc false
  def changeset_with_password(user, attrs) do
    user
    |> cast(attrs, [:cpf, :cpf_hash, :password])
    |> validate_required([:cpf, :password])
    |> validate_cpf(:cpf)
    |> encrypt_cpf()
    |> changeset(attrs)
  end

  def referral_changeset(user, attrs) do
    user
    |> cast(attrs, [
      :referral_code_gen,
      :status
    ])
  end

  def validate_cpf(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      if CPF.valid?(value) do
        []
      else
        [{field, "invalid CPF: #{value}"}]
      end
    end)
  end

  defp encrypt_cpf(%Ecto.Changeset{changes: %{cpf: cpf}} = changeset) do
    changeset
    |> put_change(:cpf, AES.encrypt(cpf))
    |> put_change(:cpf_hash, HashField.hash(cpf))
  end

  defp encrypt_cpf(changeset), do: changeset

  defp encrypt_email(%Ecto.Changeset{changes: %{email: email}} = changeset) do
    changeset
    |> put_change(:email, AES.encrypt(email))
  end

  defp encrypt_email(changeset), do: changeset

  defp encrypt_name(%Ecto.Changeset{changes: %{name: name}} = changeset) do
    changeset
    |> put_change(:name, AES.encrypt(name))
  end

  defp encrypt_name(changeset), do: changeset

  def validate_date(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      with {:ok, _data} <- Timex.parse(value, "{ISOdate}") do
        []
      else
        _ -> [{field, "invalid date"}]
      end
    end)
  end

  defp encrypt_birth_date(%Ecto.Changeset{changes: %{birth_date: birth_date}} = changeset) do
    changeset
    |> put_change(:birth_date, AES.encrypt(birth_date))
  end

  defp encrypt_birth_date(changeset), do: changeset

  defp hash_password(%Ecto.Changeset{changes: %{password: password}} = changeset) do
    changeset
    |> put_change(:password, Password.hash(password))
  end

  defp hash_password(changeset), do: changeset
end
