defmodule Crm.CustomersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Crm.Customers` context.
  """

  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> Enum.into(%{
        company_address: "some company_address",
        email: "some email",
        person_in_charge: "some person_in_charge",
        phone: "some phone",
        warehouse_address: "some warehouse_address"
      })
      |> Crm.Customers.create_customer()

    customer
  end
end
