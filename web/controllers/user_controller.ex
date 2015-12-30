defmodule UeberauthProvider.UserController do
  use UeberauthProvider.Web, :controller

  alias UeberauthProvider.User

  plug :scrub_params, "user" when action in [:create]

  def index(conn, params) do
    users = Repo.all(User)
    render conn, "index.html", users: users
  end

  def new(conn, params) do
    cs = User.registration_changeset(%User{})
    render conn, "new.html", changeset: cs
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: user_path(conn, :index))
      {:error, errored_changeset} ->
        render conn, "new.html", changeset: errored_changeset
    end
  end
end
