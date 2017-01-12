defmodule Chat.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
  end

  scope "/graphiql" do
    pipe_through :api

    forward "/", Absinthe.Plug.GraphiQL,
      schema: Chat.Schema
  end

  scope "/", Chat do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end
end
