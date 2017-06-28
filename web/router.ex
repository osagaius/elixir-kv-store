defmodule ElixirKvStore.Router do
  use ElixirKvStore.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ElixirKvStore do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    scope "/api" do
      pipe_through :api

      get "/get", KVController, :index
      get "/get/:key", KVController, :get
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirKvStore do
  #   pipe_through :api
  # end
end
