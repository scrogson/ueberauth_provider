defmodule UeberauthProvider.User do
  use UeberauthProvider.Web, :model

  schema "users" do
    field :email, :string
    field :name, :string
    field :encrypted_password
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps
  end

  def registration_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(email name password password_confirmation), ~w())
    |> validate_format(:email, ~r/@/)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> encrypt_password()
  end

  def check_password(%__MODULE__{encrypted_password: crypted} = user, password) do
    Comeonin.Bcrypt.checkpw(password, crypted)
  end
  def check_password(_, _), do: false

  defp encrypt_password(%{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :encrypted_password, hash_password(password))
  end

  defp encrypt_password(changeset), do: changeset

  defp hash_password(password) do
    Comeonin.Bcrypt.hashpwsalt(password)
  end
end
