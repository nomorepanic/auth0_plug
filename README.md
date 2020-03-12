# Auth0 plug

A plug for verifing Auth0 JWTs.


## Usage

Add to dependencies:

```elixir
{:auth0_plug, "~> 1.3"}
```

Put in your router after match and before dispatch:


```elixir
plug(:match)
plug(Auth0Plug)
plug(:dispatch)
```

## Configuration

```elixir
config :auth0_plug,
  secret: "secret",
  realm: "realm",
  extractions: [{nil, :auth0_jwt}]
```

You can find the jwt in conn.private:

```elixir
conn.private[:auth0_jwt]
```

In case of failure the plug will return automatically a 401. If you don't want
that, you can disable it in the options:

```elixir
config :auth0_plug,
    return_401: false
```

If you want to customize the error message:


```elixir
config :auth0_plug,
    unauthorized_message: "Your credentials are invalid"
```


It's possible to specify which keys to extract from the JWT:

```elixir
config :auth0_plug,
    extractions: [
        {"jwt_claim", :conn_private_key},
        {nil, :extracts_all_the_jwt}
    ]
```


To exclude paths from 401:

```elixir
config :auth0_plug,
    exclude_from_401: ["/public", "/public/:id"]
```
