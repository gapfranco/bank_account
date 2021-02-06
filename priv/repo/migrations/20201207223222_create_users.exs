defmodule BankAccount.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :cpf, :binary, null: false
      add :cpf_hash, :binary, null: false
      add :email, :binary
      add :name, :binary
      add :birth_date, :binary
      add :gender, :string
      add :city, :string
      add :state, :string
      add :country, :string
      add :referral_code, :string
      add :referral_code_gen, :string
      add :password, :string
      add :status, :string, null: false, default: "pending"

      timestamps()
    end

    create unique_index(:users, [:cpf_hash])
    create unique_index(:users, [:referral_code_gen])
    create index(:users, [:referral_code])
  end
end
