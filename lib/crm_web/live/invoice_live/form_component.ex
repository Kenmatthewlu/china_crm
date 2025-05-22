defmodule CrmWeb.InvoiceLive.FormComponent do
  use CrmWeb, :live_component

  alias Crm.Invoicing
  alias Crm.Customers
  alias Crm.Inventory
  alias Crm.Invoicing.Invoice
  alias Crm.Invoicing.InvoiceItem

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto">
      <.header>
        {@title}
        <:subtitle>Use this form to manage invoice records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="invoice-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="mb-4">
          <.input type="date" field={@form[:date]} label="Date" />
        </div>

        <div class="mb-4">
          <.input type="select" field={@form[:customer_id]} label="Customer" options={@customer_options} prompt="Select a customer" />
        </div>

        <div class="mb-4">
          <.input type="text" field={@form[:invoice_number]} label="Invoice Number" />
        </div>

        <div class="mt-6 mb-6">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-semibold">Invoice Items</h3>
            <.button type="button" phx-click="add-item" phx-target={@myself}>Add Item</.button>
          </div>

          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/4">Product</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/6">Quantity</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/6">Unit Price</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/6">Discount (%)</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/6">Total</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider w-1/12">Actions</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <%= for {item, index} <- Enum.with_index(@invoice_items) do %>
                  <tr>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <select
                        class="mt-2 pl-3 py-3 block w-full rounded-md border border-gray-300 bg-white shadow-sm focus:border-zinc-400 focus:ring-0 sm:text-sm"
                        name={"invoice[items][#{index}][product_id]"}
                        id={"invoice_items_#{index}_product_id"}
                        phx-change="product-selected"
                        phx-target={@myself}
                      >
                        <option value="">Select a product</option>
                        <%= for {name, id} <- @product_options do %>
                          <option value={id} selected={item.product_id == id}><%= name %></option>
                        <% end %>
                      </select>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <.input
                        type="number"
                        name={"invoice[items][#{index}][quantity]"}
                        id={"invoice_items_#{index}_quantity"}
                        value={item.quantity}
                        min="1"
                        class="mt-1 block w-full pl-3 py-3 text-lg border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 rounded-md"
                        phx-change="update-item-total"
                        phx-target={@myself}
                        style="appearance-none; -moz-appearance: textfield;"
                      />
                    </td>

                    <td class="px-6 py-4 whitespace-nowrap">
                      <% product_price = if item.product_id do
                          product = Map.get(@products_map, item.product_id)
                           if product, do: product.price_retail, else: nil
                         else
                           nil
                         end %>
                      <div class="text-sm text-gray-900">
                        <%= if product_price do %>
                          <%= product_price %>
                        <% else %>
                          -
                        <% end %>
                        <.input
                          type="hidden"
                          name={"invoice[items][#{index}][unit_price]"}
                          id={"invoice_items_#{index}_unit_price"}
                          value={product_price}
                        />
                      </div>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <.input
                        type="number"
                        name={"invoice[items][#{index}][discount]"}
                        id={"invoice_items_#{index}_discount"}
                        value={item.discount}
                        step="any"
                        min="0"
                        max="100"
                        class="mt-1 block w-full pl-3 py-3 text-lg border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 rounded-md h-12"
                        phx-change="update-item-total"
                        phx-target={@myself}
                        style="appearance-none; -moz-appearance: textfield;"
                      />
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">

                        <%= if item.quantity && item.unit_price do %>
                          <% item_total = Decimal.mult(Decimal.new(item.quantity), item.unit_price) %>
                          <% discount_amount = if Decimal.compare(item.discount || Decimal.new(0), Decimal.new(0)) == :gt do
                               Decimal.mult(item_total, Decimal.div(item.discount || Decimal.new(0), Decimal.new(100)))
                             else
                               Decimal.new(0)
                             end %>
                          <%= Decimal.sub(item_total, discount_amount) %>
                        <% else %>
                          0.00
                        <% end %>
                    </td>
                    <td class="px-6 py-4 whitespace-nowrap">
                      <.button type="button" phx-click="remove-item" phx-target={@myself} phx-value-index={index}>Remove</.button>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>

        <div class="mt-4 text-right">
          <div class="text-lg font-semibold">Total: <%= @total_amount %></div>
          <input type="hidden" name="invoice[total_amount]" value={@total_amount} />
        </div>

        <:actions>
          <.button phx-disable-with="Saving...">Save Invoice</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{invoice: invoice} = assigns, socket) do
    invoice_items = if Ecto.assoc_loaded?(invoice.invoice_items) do
      invoice.invoice_items
    else
      []
    end

    # Convert invoice items to a format suitable for the form
    form_items = Enum.map(invoice_items, fn item ->
      %{id: item.id, product_id: item.product_id, quantity: item.quantity, unit_price: item.unit_price, discount: item.discount || Decimal.new(0)}
    end)

    # If there are no items, add an empty one
    form_items = if Enum.empty?(form_items), do: [%{product_id: nil, quantity: 1, unit_price: nil, discount: Decimal.new(0)}], else: form_items

    # Get customer and product options for select fields
    customer_options = Customers.list_customers()
    |> Enum.map(fn c -> {c.person_in_charge, c.id} end)

    # Get products for dropdown and create a map for easy lookup
    products = Inventory.list_products()
    product_options = products |> Enum.map(fn p -> {p.name, p.id} end)
    products_map = products |> Enum.map(fn p -> {p.id, p} end) |> Map.new()

    # Prepare changeset with nested items
    invoice_params = %{
      "customer_id" => invoice.customer_id,
      "date" => invoice.date,
      "invoice_number" => invoice.invoice_number,
      "total_amount" => invoice.total_amount,
      "items" => form_items |> Enum.with_index() |> Enum.map(fn {item, idx} -> {Integer.to_string(idx), item} end) |> Enum.into(%{})
    }
    changeset = Invoicing.change_invoice(invoice, invoice_params)

    # Calculate total
    total_amount = Invoicing.calculate_invoice_total(form_items)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:invoice_items, form_items)
     |> assign(:customer_options, customer_options)
     |> assign(:product_options, product_options)
     |> assign(:products_map, products_map)
     |> assign(:total_amount, total_amount)
     |> assign_new(:form, fn ->
       to_form(changeset)
     end)}
  end

  @impl true
  def handle_event("validate", %{"invoice" => invoice_params}, socket) do
    changeset = Invoicing.change_invoice(%Invoice{}, invoice_params)
    IO.inspect to_form(changeset)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("add-item", _, socket) do
    invoice_items = socket.assigns.invoice_items ++ [%{product_id: nil, quantity: 1, unit_price: nil, discount: Decimal.new(0)}]

    {:noreply,
     socket
     |> assign(:invoice_items, invoice_items)
     |> update_totals()}
  end

  def handle_event("remove-item", %{"index" => index}, socket) do
    index = String.to_integer(index)
    invoice_items = List.delete_at(socket.assigns.invoice_items, index)

    # Ensure there's always at least one item
    invoice_items = if Enum.empty?(invoice_items), do: [%{product_id: nil, quantity: 1, unit_price: nil, discount: Decimal.new(0)}], else: invoice_items

    {:noreply,
     socket
     |> assign(:invoice_items, invoice_items)
     |> update_totals()}
  end

  def handle_event("product-selected", %{"_target" => ["invoice", "items", index, "product_id"], "invoice" => %{"items" => items}} = params, socket) do

    product_id = get_in(items, [index, "product_id"]) |> String.to_integer()

    invoice_items = List.update_at(socket.assigns.invoice_items, String.to_integer(index), fn item ->
      product = Map.get(socket.assigns.products_map, product_id)
      %{item | product_id: product_id, unit_price: product.price_retail}
    end)

    {:noreply,
     socket
     |> assign(:invoice_items, invoice_items)
     |> update_totals()}
  end



  def handle_event("prevent-submit", _params, socket) do
    # Just prevent default form submission on Enter key
    {:noreply, socket}
  end

  def handle_event("update-item-total", %{"_target" => ["invoice", "items", index, field], "invoice" => %{"items" => items}} = params, socket) do
    # Get the current value from the form
    current_value = case field do
      "quantity" ->
        quantity_str = get_in(items, [index, "quantity"]) || ""
        if quantity_str != "", do: String.to_integer(quantity_str), else: 0
      "discount" ->
        discount_str = get_in(items, [index, "discount"]) || "0"
        if discount_str != "", do: Decimal.new(discount_str), else: Decimal.new(0)
      _ -> nil
    end |> IO.inspect

    # Update the specific item field
    invoice_items = List.update_at(socket.assigns.invoice_items, String.to_integer(index), fn item ->
      case field do
        "quantity" ->
          %{item | quantity: current_value}
        "discount" ->
          %{item | discount: current_value}
        _ -> item
      end |> IO.inspect
    end)

    {:noreply,
     socket
     |> assign(:invoice_items, invoice_items)
     |> update_totals()}
  end

  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    # Extract items from the nested params
    items_params = invoice_params["items"] || %{}

    # Convert items params to a list of maps
    items = Enum.map(items_params, fn {_index, item} ->
      %{
        product_id: if(item["product_id"] && item["product_id"] != "", do: String.to_integer(item["product_id"]), else: nil),
        quantity: if(item["quantity"] && item["quantity"] != "", do: String.to_integer(item["quantity"]), else: 0),
        unit_price: if(item["unit_price"] && item["unit_price"] != "", do: Decimal.new(item["unit_price"]), else: nil),
        discount: if(item["discount"] && item["discount"] != "", do: Decimal.new(item["discount"]), else: Decimal.new(0))
      }
    end)
    |> Enum.filter(fn item -> item.product_id != nil && item.quantity > 0 && item.unit_price != nil end)

    # Set the total_amount from our calculated value
    invoice_params = Map.put(invoice_params, "total_amount", socket.assigns.total_amount)

    save_invoice_with_items(socket, socket.assigns.action, invoice_params, items)
  end

  defp save_invoice_with_items(socket, :edit, invoice_params, items) do
    case Invoicing.update_invoice_with_items(socket.assigns.invoice, invoice_params, items) do
      {:ok, invoice} ->
        notify_parent({:saved, invoice})

        {:noreply,
         socket
         |> put_flash(:info, "Invoice updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_invoice_with_items(socket, :new, invoice_params, items) do
    case Invoicing.create_invoice_with_items(invoice_params, items) do
      {:ok, invoice} ->
        notify_parent({:saved, invoice})

        {:noreply,
         socket
         |> put_flash(:info, "Invoice created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp update_totals(socket) do
    invoice_items = socket.assigns.invoice_items
    total_amount = Invoicing.calculate_invoice_total(invoice_items)

    socket
    |> assign(:total_amount, total_amount)
  end
end
