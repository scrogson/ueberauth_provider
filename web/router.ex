defmodule UeberauthProvider.Router do
  use UeberauthProvider.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug UeberauthProvider.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", UeberauthProvider do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/login", SessionController, :new, as: :login
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete, as: :logout

    resources "/users", UserController
    resources "/clients", ClientController do
      patch "/regenerate-secret", ClientController, :regenerate_secret, as: :regenerate_secret
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", UeberauthProvider do
  #   pipe_through :api
  # end
end
