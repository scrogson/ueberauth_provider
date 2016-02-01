defmodule UeberauthProvider.ClientTest do
  use UeberauthProvider.ModelCase

  alias UeberauthProvider.Client

  setup do
    {
      :ok,
      %{
        valid_params: %{
          name: "My App",
          redirect_uri: "http://localhost:3000/auth/cool/callback",
          scopes: "cool"
        }
      }
    }
  end

  test "generates a uid when none is present", %{valid_params: params} do
    cs = Client.changeset(%Client{}, params)
    assert cs.changes.uid != nil
  end

  test "does not generate a uid when one is present on the model", %{valid_params: params} do
    cs = Client.changeset(%Client{uid: "THEUID"}, params)
    assert Map.has_key?(cs.changes, :uid) == false
  end

  test "generates a secret when none is present", %{valid_params: params} do
    cs = Client.changeset(%Client{}, params)
    assert cs.changes.secret != nil
  end

  test "does not generate a secret when one is present on the model", %{valid_params: params} do
    cs = Client.changeset(%Client{secret: "THESECRET"}, params)
    assert Map.has_key?(cs.changes, :secret) == false
  end

  test "changeset with an invalid list of hosts", %{valid_params: params} do
    params = Map.put(params, :redirect_uri, "http://example.com")
    cs = Client.changeset(%Client{}, params)
    assert cs.valid? == false
    assert Keyword.get(cs.errors, :redirect_uri) == "includes invalid uris http://example.com"
  end

  test "changeset is fine when the list of hosts is valid", %{valid_params: params} do
    cs = Client.changeset(%Client{}, params)
    assert cs.valid? == true
    assert Keyword.get(cs.errors, :redirect_uri) == nil
  end

  test "changeset validates the type is confidential or public", %{valid_params: params} do
    params = Map.put(params, :type, "confidential")
    cs = Client.changeset(%Client{}, params)
    assert cs.valid? == true

    params = Map.put(params, :type, "public")
    cs = Client.changeset(%Client{}, params)
    assert cs.valid? == true

    params = Map.put(params, :type, "not_a_thing")
    cs = Client.changeset(%Client{}, params)
    assert cs.valid? == false
    refute Keyword.get(cs.errors, :type) == nil
  end
end

