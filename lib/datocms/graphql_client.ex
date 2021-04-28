defmodule DatoCMS.GraphQLClient do
  @moduledoc """
  Documentation for DatoCMS.GraphQLClient.
  """

  alias DatoCMS.GraphQLClient.Backends.StandardClient

  def client do
    Application.get_env(:datocms_graphql_client, :config, [])
    |> Keyword.get(:backend, StandardClient)
  end

  def configure(opts) do
    client().configure(opts)
  end

  def query!(query, params \\ %{}) do
    client().query!(query, params)
  end

  def query(query, params \\ %{}) do
    client().query(query, params)
  end

  def fetch!(key, query, params \\ %{}) do
    client().fetch!(key, query, params)
  end

  def fetch(key, query, params \\ %{}) do
    client().fetch(key, query, params)
  end

  def fetch_localized!(key, locale, query, params \\ %{}) do
    client().fetch_localized!(key, locale, query, params)
  end

  def fetch_localized(key, locale, query, params \\ %{}) do
    client().fetch_localized(key, locale, query, params)
  end

  def fetch_all!(key, query, params \\ %{}) do
    client().fetch_all!(key, query, params)
  end

  def fetch_all(key, query, params \\ %{}) do
    client().fetch_all(key, query, params)
  end

  def fetch_all_localized!(key, locale, query, params \\ %{}) do
    client().fetch_all_localized!(key, locale, query, params)
  end

  def fetch_all_localized(key, locale, query, params \\ %{}) do
    client().fetch_all_localized(key, locale, query, params)
  end
end
