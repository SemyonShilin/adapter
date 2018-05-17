defmodule AdapterWeb.Router do
  use AdapterWeb, :router

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

  scope "/", AdapterWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
   scope "/api", AdapterWeb do
     pipe_through :api
     # messengers routes
     scope "/messengers" do
       get "/", MessengerController, :index
       get "/:name", MessengerController, :show
       post "/", MessengerController, :create
       delete "/:name", MessengerController, :delete

       post "/:name/up", MessengerController, :up
       post "/:name/down", MessengerController, :down
     end

     #bots
     scope "/bots" do
       get "/", BotController, :index
       get "/:uid", BotController, :show
       post "/", BotController, :create
       delete "/:uid", BotController, :delete

       post "/:uid/up", BotController, :up
       post "/:uid/down", BotController, :down
       post "/:uid/send",  BotController, :send
     end
   end
end
