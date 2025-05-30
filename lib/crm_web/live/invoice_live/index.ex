defmodule CrmWeb.InvoiceLive.Index do
  use CrmWeb, :live_view

  alias Crm.Invoicing
  alias Crm.Invoicing.Invoice

  @impl true
  def mount(_params, _session, socket) do
    # We're using list_invoices which already preloads customer and invoice_items
    # as we updated the Invoicing context
    {:ok, stream(socket, :invoices, Invoicing.list_invoices())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Invoice")
    |> assign(:invoice, Invoicing.get_invoice!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Invoice")
    |> assign(:invoice, %Invoice{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Invoices")
    |> assign(:invoice, nil)
  end

  @impl true
  def handle_info({CrmWeb.InvoiceLive.FormComponent, {:saved, invoice}}, socket) do
    {:noreply, stream_insert(socket, :invoices, invoice)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    invoice = Invoicing.get_invoice!(id)
    {:ok, _} = Invoicing.delete_invoice(invoice)

    {:noreply, stream_delete(socket, :invoices, invoice)}
  end
end
