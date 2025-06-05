defmodule Crm.Repo.Migrations.AddDescriptionToInvoiceItems do
  use Ecto.Migration

  def change do
    alter table(:invoice_items) do
      add :description, :text
    end
  end
end
