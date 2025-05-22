defmodule Crm.InvoicingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Crm.Invoicing` context.
  """

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(attrs \\ %{}) do
    {:ok, invoice} =
      attrs
      |> Enum.into(%{
        date: ~D[2025-05-21],
        discount: "120.5",
        total_amount: "120.5"
      })
      |> Crm.Invoicing.create_invoice()

    invoice
  end
end
