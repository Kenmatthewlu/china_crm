defmodule Crm.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Crm.Inventory` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "some name",
        price_retail: "120.5",
        price_supplier: "120.5",
        sku_id: "some sku_id",
        stock: 42
      })
      |> Crm.Inventory.create_product()

    product
  end
end
