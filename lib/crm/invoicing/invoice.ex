defmodule Crm.Invoicing.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invoices" do
    field :date, :date
    field :invoice_number, :string
    field :total_amount, :decimal
    
    belongs_to :customer, Crm.Customers.Customer
    has_many :invoice_items, Crm.Invoicing.InvoiceItem, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:date, :invoice_number, :total_amount, :customer_id])
    |> validate_required([:date, :customer_id])
    |> unique_constraint(:invoice_number)
    |> foreign_key_constraint(:customer_id)
  end
end
