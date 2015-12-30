defmodule UeberauthProvider.ViewHelpers do
  def current_user(conn), do: conn.assigns[:current_user]
end
