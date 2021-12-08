import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tfl_demo, TflDemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "O3d8ph36j/utyIs90blGhyEMEy8R4/9Ua0kEsFPNPv1ZuCGCSKm/Ac0xywkBs9QQ",
  server: false

# In test we don't send emails.
config :tfl_demo, TflDemo.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
