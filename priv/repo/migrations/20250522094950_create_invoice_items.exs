defmodule Crm.Repo.Migrations.CreateInvoiceItems do
  use Ecto.Migration

  def change do
    create table(:invoice_items) do
      add :quantity, :integer
      add :unit_price, :decimal
      add :invoice_id, references(:invoices, on_delete: :nothing)
      add :product_id, references(:products, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:invoice_items, [:invoice_id])
    create index(:invoice_items, [:product_id])
  end
end
