defmodule UeberauthProvider.Repo.Migrations.AddUserToClients do
  use Ecto.Migration

  def change do
    alter table(:oauth_clients) do
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
