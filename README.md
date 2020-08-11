# DatoCMS GraphQL Client

# Initialization

In config/config.exs:

```elixir
config :my_app,
  api_key: System.get_env("DATOCMS_API_KEY")
```

```elixir
datocms_api_key = Application.fetch_env!(:my_app, :api_key)
DatoCMS.GraphQLClient.config(datocms_api_key)
```

# Queries

* single items: `DatoCMS.GraphQLClient.fetch!(:foo, "{ bar }").bar`,
* localized single items: `DatoCMS.GraphQLClient.fetch_localized!(:foo, :en, "{ bar }")`,
* collections: `DatoCMS.GraphQLClient.fetch_all!(:allFoos, "{ bar }")`,
* localized collections: `DatoCMS.GraphQLClient.fetch_all_localized!(:allFoos, :en, "{ bar }")`.
