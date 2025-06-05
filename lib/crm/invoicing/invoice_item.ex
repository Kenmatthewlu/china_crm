defmodule Crm.Invoicing.InvoiceItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoice_items" do
    field :quantity, :integer
    field :unit_price, :decimal
    field :discount, :decimal, default: 0
    field :description, :string
    
    belongs_to :invoice, Crm.Invoicing.Invoice
    belongs_to :product, Crm.Inventory.Product

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invoice_item, attrs) do
    invoice_item
    |> cast(attrs, [:quantity, :unit_price, :discount, :description, :invoice_id, :product_id])
    |> validate_required([:quantity, :unit_price, :invoice_id, :product_id])
    |> foreign_key_constraint(:invoice_id)
    |> foreign_key_constraint(:product_id)
  end
end
