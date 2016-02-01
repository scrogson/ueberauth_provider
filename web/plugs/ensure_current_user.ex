defmodule UeberauthProvider.EnsureCurrentUser do
  import Phoenix.Controller
  import Plug.Conn

  def init(opts \\ []), do: opts

  def call(conn, _opts) do
    if get_session(conn, :user_id) do
      conn
    else
      conn
      |> put_flash(:error, "Login required")
      |> redirect(to: "/")
    end
  end
end
