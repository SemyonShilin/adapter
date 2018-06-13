defmodule Adapter.Router do
  use Adapter.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  forward "/wobserver", Wobserver.Web.Router

  scope "/webhooks" do
    pipe_through :api

    #receive webhook
    post "/:platform/:uid", Adapter.WebhookController, :receive
  end

  # Other scopes may use custom stacks.
   scope "/api/v0", Adapter.Api.V0 do
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
