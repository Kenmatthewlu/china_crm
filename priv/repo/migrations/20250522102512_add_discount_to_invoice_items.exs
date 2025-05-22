defmodule Crm.Repo.Migrations.AddDiscountToInvoiceItems do
  use Ecto.Migration

  def change do
    alter table(:invoice_items) do
      add :discount, :decimal, default: 0
    end
  end
end
