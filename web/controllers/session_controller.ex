defmodule UeberauthProvider.SessionController do
  use UeberauthProvider.Web, :controller

  alias UeberauthProvider.User

  plug :scrub_params, "session" when action in [:create]

  def new(conn, params) do
    render conn, "new.html"
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    user = Repo.get_by(User, email: email)
    if user && User.check_password(user, password) do
      conn
      |> put_session(:user_id, user.id)
      |> put_flash(:info, "Logged in")
      |> redirect(to: user_path(conn, :index))
    else
      conn
      |> put_flash(:error, "Not found")
      |> redirect(to: login_path(conn, :new))
    end
  end

  def create(conn, _) do
    redirect(conn, to: login_path(conn, :new))
  end

  def delete(conn, _) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end
