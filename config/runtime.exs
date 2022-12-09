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
    url: [host: System.get_env("RENDER_EXTERNAL_HOSTNAME"), port: 10000],
    check_origin: true
end
