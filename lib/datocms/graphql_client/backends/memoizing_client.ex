defmodule DatoCMS.GraphQLClient.Backends.MemoizingClient do
  alias DatoCMS.GraphQLClient.Backends.StandardClient
  use Memoize

  def config(datocms_api_key) do
    StandardClient.config(datocms_api_key)
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
