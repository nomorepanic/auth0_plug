import Config

config :auth0_plug,
  secret: "secret",
  realm: "realm",
  conn_key: :auth0_plug_jwt,
  key_to_extract: nil,
  return_401: true,
  unauthorized_message: "Your credentials are invalid"
