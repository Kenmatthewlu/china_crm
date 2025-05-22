defmodule Crm.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :sku_id, :string
      add :name, :string
      add :stock, :integer
      add :price_retail, :decimal
      add :price_supplier, :decimal

      timestamps(type: :utc_datetime)
    end
  end
end
