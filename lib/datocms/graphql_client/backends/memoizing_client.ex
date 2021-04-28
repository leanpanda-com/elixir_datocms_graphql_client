defmodule DatoCMS.GraphQLClient.Backends.MemoizingClient do
  alias DatoCMS.GraphQLClient.Backends.StandardClient
  use Memoize

  def configure(opts \\ []) do
    StandardClient.configure(opts)
  end

  defmemo query!(query, params \\ %{}) do
    StandardClient.query!(query, params)
  end

  defmemo query(query, params \\ %{}) do
    StandardClient.query(query, params)
  end

  defmemo fetch!(key, query, params \\ %{}) do
    StandardClient.fetch!(key, query, params)
  end

  defmemo fetch(key, query, params \\ %{}) do
    StandardClient.fetch(key, query, params)
  end

  defmemo fetch_localized!(key, locale, query, params \\ %{}) do
    StandardClient.fetch_localized!(key, locale, query, params)
  end

  defmemo fetch_localized(key, locale, query, params \\ %{}) do
    StandardClient.fetch_localized(key, locale, query, params)
  end

  defmemo fetch_all!(key, query, params \\ %{}) do
    StandardClient.fetch_all!(key, query, params)
  end

  defmemo fetch_all(key, query, params \\ %{}) do
    StandardClient.fetch_all(key, query, params)
  end

  defmemo fetch_all_localized!(key, locale, query, params \\ %{}) do
    StandardClient.fetch_all_localized!(key, locale, query, params)
  end

  defmemo fetch_all_localized(key, locale, query, params \\ %{}) do
    StandardClient.fetch_all_localized(key, locale, query, params)
  end
end
