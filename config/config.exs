import Config

config :auth0_plug,
  secret: "secret",
  realm: "realm",
  extractions: [],
  return_401: true,
  exclude_from_401: [],
  unauthorized_message: "Your credentials are invalid"
