defmodule UeberauthProvider.Client do
  use UeberauthProvider.Web, :model

  @allowed_non_tls_hosts ~w(localhost)
  @default_client_type "confidential"
  @allowed_client_types ~w(confidential public)

  schema "oauth_clients" do
    field :name, :string
    field :uid, :string
    field :type, :string, default: @default_client_type
    field :secret, :string
    field :redirect_uri, :string
    field :scopes, :string, default: ""

    belongs_to :user, UeberauthProvider.User

    timestamps
  end

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(name redirect_uri scopes user_id), ~w(type))
    |> maybe_generate_uid()
    |> maybe_generate_secret()
    |> validate_change(:redirect_uri, &validate_redirect_uris/2)
    |> validate_inclusion(:type, @allowed_client_types)
  end

  def update_changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(), ~w(redirect_uri scopes name type))
    |> validate_change(:redirect_uri, &validate_redirect_uris/2)
    |> validate_inclusion(:type, @allowed_client_types)
  end

  def regenerate_secret_changeset(model) do
    model
    |> cast(%{}, ~w(), ~w())
    |> generate_secret()
  end

  defp maybe_generate_uid(changeset) do
    if changeset.model.uid do
      changeset
    else
      generate_uid(changeset)
    end
  end

  defp generate_uid(changeset), do: put_change(changeset, :uid, UUID.uuid4(:hex))

  defp maybe_generate_secret(changeset) do
    if changeset.model.secret do
      changeset
    else
      generate_secret(changeset)
    end
  end

  defp generate_secret(changeset), do: put_change(changeset, :secret, UUID.uuid4(:hex))

  defp validate_redirect_uris(:redirect_uri, ""), do: [:redirect_uri, "is required"]

  defp validate_redirect_uris(:redirect_uri, txt) do
    invalid_uris = parse_redirect_uris(txt)
    |> detect_invalid_uris
    |> Enum.map(&to_string/1)

    if length(invalid_uris) > 0 do
      [redirect_uri: "includes invalid uris #{Enum.join(invalid_uris, ", ")}"]
    else
      []
    end
  end

  defp parse_redirect_uris(txt) do
    txt
    |> String.split("\n")
    |> Enum.map(&String.strip/1)
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&URI.parse/1)
  end

  defp detect_invalid_uris(list), do: detect_invalid_uris(list, []) |> Enum.reverse
  defp detect_invalid_uris([h|t], acc) do
    if valid_uri?(h) do
      detect_invalid_uris(t, acc)
    else
      detect_invalid_uris(t, [h | acc])
    end
  end
  defp detect_invalid_uris([], acc), do: acc

  defp valid_uri?(%URI{scheme: "https"}), do: true
  defp valid_uri?(%URI{host: host}) when host in @allowed_non_tls_hosts, do: true
  defp valid_uri?(_), do: false
end
