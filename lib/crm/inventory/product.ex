defmodule Crm.Inventory.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :sku_id, :string
    field :stock, :integer
    field :price_retail, :decimal
    field :price_supplier, :decimal
    field :supplier, :string
    field :remarks, :string

    has_many :invoice_items, Crm.Invoicing.InvoiceItem
    
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:sku_id, :name, :stock, :price_retail, :price_supplier, :supplier, :remarks])
    |> validate_required([:sku_id, :name, :stock, :price_retail, :price_supplier])
  end
end
