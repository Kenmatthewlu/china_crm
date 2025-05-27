defmodule CrmWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use CrmWeb, :controller` and
  `use CrmWeb, :live_view`.
  """
  use CrmWeb, :html

  embed_templates "layouts/*"

  # Add an explicit render function for the print layout
  def render("print.html", assigns) do
    print(assigns)
  end
end
