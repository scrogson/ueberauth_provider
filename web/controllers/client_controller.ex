defmodule UeberauthProvider.ClientController do
  use UeberauthProvider.Web, :controller

  alias UeberauthProvider.Client

  plug UeberauthProvider.EnsureCurrentUser
  plug :scrub_params, "client" when action in [:create, :update]

  def index(conn, _params) do
    user = current_user(conn)
    user_id = user.id
    clients = Repo.all(Ecto.assoc(user, :oauth_clients))
    render(conn, "index.html", clients: clients)
  end

  def new(conn, _params) do
    changeset = Client.changeset(%Client{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"client" => client_params}) do
    user = current_user(conn)
    client = Ecto.build_assoc(user, :oauth_clients)
    changeset = Client.changeset(client, client_params)

    case Repo.insert(changeset) do
      {:ok, _client} ->
        conn
        |> put_flash(:info, "Client created successfully.")
        |> redirect(to: client_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def create(conn, _) do
    conn
    |> put_status(400)
    |> put_flash(:error, "Bad request")
    |> render("new.html", changeset: Client.changeset(%Client{}))
  end

  def show(conn, %{"id" => id}) do
    client = Repo.get!(Client, id)
    render(conn, "show.html", client: client)
  end

  def edit(conn, %{"id" => id}) do
    client = Repo.get!(Client, id)
    changeset = Client.changeset(client)
    render(conn, "edit.html", client: client, changeset: changeset)
  end

  def update(conn, %{"id" => id, "client" => client_params}) do
    client = Repo.get!(Client, id)
    changeset = Client.changeset(client, client_params)

    case Repo.update(changeset) do
      {:ok, client} ->
        conn
        |> put_flash(:info, "Client updated successfully.")
        |> redirect(to: client_path(conn, :show, client))
      {:error, changeset} ->
        render(conn, "edit.html", client: client, changeset: changeset)
    end
  end

  def regenerate_secret(conn, %{"client_id" => id}) do
    client = current_user(conn)
    |> Ecto.assoc(:oauth_clients)
    |> Repo.get_by(id: id)

    cs = Client.regenerate_secret_changeset(client)
    if cs.valid? do
      client = Repo.update!(cs)
      conn
      |> put_flash(:info, "Secret updated")
      |> redirect(to: client_path(conn, :show, client.id))
    else
      conn
      |> put_flash(:error, "Could not regenerate secret")
      |> redirect(to: client_path(conn, :show, client.id))
    end
  end

  def delete(conn, %{"id" => id}) do
    client = Repo.get!(Client, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(client)

    conn
    |> put_flash(:info, "Client deleted successfully.")
    |> redirect(to: client_path(conn, :index))
  end
end
