defmodule UeberauthProvider.CurrentUser do
  import Plug.Conn

  def init(opts \\ []), do: opts

  def call(conn, _opts) do
    assign(conn, :current_user, user_from_session(conn))
  end

  defp user_from_session(conn) do
    case get_session(conn, :user_id) do
      nil -> nil
      id -> UeberauthProvider.Repo.get(UeberauthProvider.User, id)
    end
  end
end
