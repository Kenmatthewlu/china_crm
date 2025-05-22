defmodule Crm.InvoicingTest do
  use Crm.DataCase

  alias Crm.Invoicing

  describe "invoices" do
    alias Crm.Invoicing.Invoice

    import Crm.InvoicingFixtures

    @invalid_attrs %{date: nil, discount: nil, total_amount: nil}

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Invoicing.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Invoicing.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      valid_attrs = %{date: ~D[2025-05-21], discount: "120.5", total_amount: "120.5"}

      assert {:ok, %Invoice{} = invoice} = Invoicing.create_invoice(valid_attrs)
      assert invoice.date == ~D[2025-05-21]
      assert invoice.discount == Decimal.new("120.5")
      assert invoice.total_amount == Decimal.new("120.5")
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Invoicing.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()
      update_attrs = %{date: ~D[2025-05-22], discount: "456.7", total_amount: "456.7"}

      assert {:ok, %Invoice{} = invoice} = Invoicing.update_invoice(invoice, update_attrs)
      assert invoice.date == ~D[2025-05-22]
      assert invoice.discount == Decimal.new("456.7")
      assert invoice.total_amount == Decimal.new("456.7")
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Invoicing.update_invoice(invoice, @invalid_attrs)
      assert invoice == Invoicing.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Invoicing.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Invoicing.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Invoicing.change_invoice(invoice)
    end
  end
end
