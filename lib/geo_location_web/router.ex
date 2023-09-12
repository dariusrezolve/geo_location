defmodule GeoLocationWeb.Router do
  use GeoLocationWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GeoLocationWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug(OpenApiSpex.Plug.PutApiSpec, module: GeoLocation.ApiSpec)
  end

  pipeline :openapi do
    plug OpenApiSpex.Plug.PutApiSpec, module: GeoLocation.ApiSpec
  end

  scope "/api", GeoLocationWeb do
    pipe_through :api

    get "/:ip", GeoLocationController, :get_by_ip
  end

  scope "/" do
    scope "/openapi" do
      pipe_through :openapi
      get "/", OpenApiSpex.Plug.RenderSpec, []
    end

    get "/doc", OpenApiSpex.Plug.SwaggerUI, path: "/openapi"
  end

  # Other scopes may use custom stacks.
  # scope "/api", GeoLocationWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:geo_location, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GeoLocationWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
