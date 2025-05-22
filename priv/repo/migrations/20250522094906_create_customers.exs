defmodule Crm.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers) do
      add :person_in_charge, :string
      add :email, :string
      add :company_address, :text
      add :warehouse_address, :text
      add :phone, :string

      timestamps(type: :utc_datetime)
    end
  end
end
