defmodule Crm.Repo.Migrations.AddSupplierAndRemarksToProducts do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :supplier, :string
      add :remarks, :text
    end
  end
end
