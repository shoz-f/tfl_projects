defmodule TflDemoWeb.Router do
  use TflDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TflDemoWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TflDemoWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/artstyle", ArtStyleLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", TflDemoWeb do
  #   pipe_through :api
  # end
end
