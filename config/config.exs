import Config

config :auth0_plug,
  secret: "secret",
  realm: "realm",
  conn_key: :auth0_plug_jwt,
  extractions: [],
  return_401: true,
  exclude_from_401: [],
  unauthorized_message: "Your credentials are invalid"
