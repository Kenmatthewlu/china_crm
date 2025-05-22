defmodule Crm.Repo.Migrations.AddInvoiceNumberAndRemoveDiscount do
  use Ecto.Migration

  def change do
    alter table(:invoices) do
      add :invoice_number, :string
      remove :discount
    end
    
    create index(:invoices, [:invoice_number], unique: true)
  end
end
