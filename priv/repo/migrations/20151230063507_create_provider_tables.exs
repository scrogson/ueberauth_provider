defmodule UeberauthProvider.Repo.Migrations.CreateProviderTables do
  use Ecto.Migration

  def change do
    create table(:oauth_clients) do
      add :name, :string, null: false
      add :type, :string, null: false
      add :uid, :string, null: false
      add :secret, :string, null: false
      add :redirect_uri, :text, null: false # \n separated list of redirect uris
      add :scopes, :text, null: false, default: ""

      timestamps
    end

    create unique_index(:oauth_clients, [:uid])

    create table(:oauth_access_grants) do
      add :resource_owner_id, :integer, null: false
      add :client_id, references(:oauth_clients)
      add :token, :string, null: false
      add :expires_in, :integer, null: false
      add :redirect_uri, :text, null: false
      add :inserted_at, :datetime, null: false
      add :revoked_at, :datetime
      add :scopes, :string
    end

    create unique_index(:oauth_access_grants, [:token])

    create table(:oauth_access_tokens) do
      add :resource_owner_id, :integer
      add :client_id, references(:oauth_clients)
      add :token, :text, null: false
      add :refresh_token, :text
      add :expires_in, :integer, null: false
      add :inserted_at, :datetime, null: false
      add :revoked_at, :datetime
      add :scopes, :string
    end

    create index(:oauth_access_tokens, [:resource_owner_id])
    create unique_index(:oauth_access_tokens, [:token])
    create unique_index(:oauth_access_tokens, [:refresh_token])
  end
end
