defmodule CrmWeb.InvoiceLive.Show do
  use CrmWeb, :live_view

  alias Crm.Invoicing

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:invoice, Invoicing.get_invoice!(id))}
  end

  defp page_title(:show), do: "Show Invoice"
  defp page_title(:edit), do: "Edit Invoice"
end
