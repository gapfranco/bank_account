defmodule BankAccountWeb.Router do
  use BankAccountWeb, :router
  alias BankAccount.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/api", BankAccountWeb do
    pipe_through :api
    post "/users/sign_in", UserController, :sign_in
    post "/users/sign_on", UserController, :sign_on
  end

  scope "/api", BankAccountWeb do
    pipe_through [:api, :jwt_authenticated]
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BankAccountWeb.Telemetry
    end
  end
end
