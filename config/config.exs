import Config

config :plug_cowboy,
  stream_handlers: [:cowboy_telemetry_h, :cowboy_stream_h]

import_config "#{config_env()}.exs"
