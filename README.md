# Auth0 plug

A plug for verifing Auth0 JWTs.


## Usage

Add to dependencies:

```elixir
{:auth0_plug, "~> 0.1"}
```

Configuration:

```elixir
config :auth0_plug,
  secret: "secret",
  realm: "realm",
  conn_key: :auth0_plug_jwt
```

You can find the jwt in conn.private:

```elixir
conn.private[:auth0_plug_jwt]
```

In case of failure the plug will return automatically a 401. If you don't want
that, you can disable it in the options:

```elixir
config :auth0_plug,
    return_401: false
```
