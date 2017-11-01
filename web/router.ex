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
    scope "/api" do
      pipe_through :api

      get "/get", KVController, :index
      post "/delete/:key", KVController, :delete
      get "/get/:key", KVController, :get
      get "/get_ttl/:key", KVController, :get_ttl
      post "/add", KVController, :add
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirKvStore do
  #   pipe_through :api
  # end
end
