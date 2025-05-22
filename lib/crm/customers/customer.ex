defmodule Crm.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :person_in_charge, :string
    field :email, :string
    field :company_address, :string
    field :warehouse_address, :string
    field :phone, :string

    has_many :invoices, Crm.Invoicing.Invoice
    
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:person_in_charge, :email, :company_address, :warehouse_address, :phone])
    |> validate_required([:person_in_charge, :email, :company_address, :warehouse_address, :phone])
  end
end
