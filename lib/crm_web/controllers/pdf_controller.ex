defmodule CrmWeb.PdfController do
  use CrmWeb, :controller

  alias Crm.Invoicing
  alias Crm.Customers
  import Phoenix.HTML
  import Phoenix.Component

  def invoice(conn, %{"id" => id}) do
    invoice = Invoicing.get_invoice!(id)
    
    # Render a clean printable version of the invoice
    # Use print layout for styling but disable app layout to remove navigation
    conn
    |> put_layout(false)
    |> put_root_layout({CrmWeb.Layouts, :print})
    |> render(:print, %{invoice: invoice})
  end
end
