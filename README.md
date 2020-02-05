# DatoCMS GraphQL Client

# Initialization

# Queries

* single items: `fetch!(:foo, "{ bar }").bar`,
* localized single items: `fetch_localized!(:foo, :en, "{ bar }")`,
* collections: `fetch_all!(:allFoos, "{ bar }")`,
* localized collections: `fetch_all_localized!(:allFoos, :en, "{ bar }")`.
