defmodule Crm.Invoicing do
  @moduledoc """
  The Invoicing context.
  """

  import Ecto.Query, warn: false
  alias Crm.Repo

  alias Crm.Invoicing.Invoice
  alias Crm.Invoicing.InvoiceItem
  alias Crm.Inventory.Product

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Repo.all(Invoice)
    |> Repo.preload([:customer, [invoice_items: :product]])
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id) do
    Repo.get!(Invoice, id)
    |> Repo.preload([:customer, invoice_items: [product: []]])
  end

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(%{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(attrs \\ %{}) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> Repo.insert()
  end

  def create_invoice_with_items(attrs \\ %{}, items \\ []) do
    Repo.transaction(fn ->
      with {:ok, invoice} <- create_invoice(attrs),
           {:ok, _items} <- create_invoice_items(invoice, items) do
        get_invoice!(invoice.id)
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  def update_invoice_with_items(%Invoice{} = invoice, attrs, items) do
    Repo.transaction(fn ->
      with {:ok, invoice} <- update_invoice(invoice, attrs),
           {:ok, _} <- delete_invoice_items(invoice),
           {:ok, _items} <- create_invoice_items(invoice, items) do
        get_invoice!(invoice.id)
      else
        {:error, changeset} -> Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Deletes a invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{data: %Invoice{}}

  """
  def change_invoice(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
  end

  # Invoice Items functions

  def list_invoice_items(invoice_id) do
    query = from i in InvoiceItem,
            where: i.invoice_id == ^invoice_id,
            preload: [:product]
    Repo.all(query)
  end

  def get_invoice_item!(id), do: Repo.get!(InvoiceItem, id) |> Repo.preload(:product)

  def create_invoice_item(attrs \\ %{}) do
    %InvoiceItem{}
    |> InvoiceItem.changeset(attrs)
    |> Repo.insert()
  end

  def create_invoice_items(invoice, items) do
    results = Enum.map(items, fn item ->
      create_invoice_item(Map.put(item, :invoice_id, invoice.id))
    end)

    if Enum.any?(results, fn {status, _} -> status == :error end) do
      # Find the first error and return it
      Enum.find(results, fn {status, _} -> status == :error end)
    else
      {:ok, Enum.map(results, fn {:ok, item} -> item end)}
    end
  end

  def update_invoice_item(%InvoiceItem{} = invoice_item, attrs) do
    invoice_item
    |> InvoiceItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_invoice_item(%InvoiceItem{} = invoice_item) do
    Repo.delete(invoice_item)
  end

  def delete_invoice_items(%Invoice{} = invoice) do
    query = from i in InvoiceItem, where: i.invoice_id == ^invoice.id
    {count, _} = Repo.delete_all(query)
    {:ok, count}
  end

  def change_invoice_item(%InvoiceItem{} = invoice_item, attrs \\ %{}) do
    InvoiceItem.changeset(invoice_item, attrs)
  end

  # Calculate total for an invoice based on its items
  def calculate_invoice_total(invoice_items) do
    Enum.reduce(invoice_items, Decimal.new(0), fn item, acc ->
      if item.quantity && item.unit_price do
        item_total = Decimal.mult(item.unit_price, Decimal.new(item.quantity))

        # Apply per-item discount if present
        discounted_total = if item.discount && Decimal.compare(item.discount, Decimal.new(0)) == :gt do
          discount_amount = Decimal.mult(item_total, Decimal.div(item.discount, Decimal.new(100)))
          Decimal.sub(item_total, discount_amount)
        else
          item_total
        end

        Decimal.add(acc, discounted_total)
      else
        acc
      end
    end)
  end
end
