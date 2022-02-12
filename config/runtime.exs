import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

if config_env() == :prod do
  config :hug, HugWeb.Endpoint,
    server: true,
    http: [port: {:system, "PORT"}],
    url: [host: "server.hug.hihaheho.com", port: 443],
    check_origin: true
end
