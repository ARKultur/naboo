import Config

config :naboo, Naboo.Endpoint,
  code_reloader: true,
  check_origin: false,
  watchers: [],
  live_reload: [
    patterns: [
      ~r{lib/naboo/.*(ee?x)$},
      ~r{lib/api/.*(ee?x)$},
      ~r{lib/health/.*(ee?x)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
