defmodule Crm.InventoryTest do
  use Crm.DataCase

  alias Crm.Inventory

  describe "products" do
    alias Crm.Inventory.Product

    import Crm.InventoryFixtures

    @invalid_attrs %{name: nil, sku_id: nil, stock: nil, price_retail: nil, price_supplier: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Inventory.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Inventory.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{name: "some name", sku_id: "some sku_id", stock: 42, price_retail: "120.5", price_supplier: "120.5"}

      assert {:ok, %Product{} = product} = Inventory.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.sku_id == "some sku_id"
      assert product.stock == 42
      assert product.price_retail == Decimal.new("120.5")
      assert product.price_supplier == Decimal.new("120.5")
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{name: "some updated name", sku_id: "some updated sku_id", stock: 43, price_retail: "456.7", price_supplier: "456.7"}

      assert {:ok, %Product{} = product} = Inventory.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.sku_id == "some updated sku_id"
      assert product.stock == 43
      assert product.price_retail == Decimal.new("456.7")
      assert product.price_supplier == Decimal.new("456.7")
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_product(product, @invalid_attrs)
      assert product == Inventory.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Inventory.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Inventory.change_product(product)
    end
  end
end
