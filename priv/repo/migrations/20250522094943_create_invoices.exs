defmodule Crm.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :date, :date
      add :discount, :decimal
      add :total_amount, :decimal
      add :customer_id, references(:customers, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:invoices, [:customer_id])
  end
end
