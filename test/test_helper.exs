ExUnit.start

Mix.Task.run "ecto.create", ~w(-r UeberauthProvider.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r UeberauthProvider.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(UeberauthProvider.Repo)

