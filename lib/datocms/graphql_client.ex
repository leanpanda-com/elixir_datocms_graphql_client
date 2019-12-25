defmodule DatoCMS.GraphQLClient do
  @moduledoc """
  Documentation for DatoCMS.GraphQLClient.
  """

  @datocms_graphql_endpoint "https://graphql.datocms.com/"
  @per_page 100

  def config(datocms_api_key) do
    Neuron.Config.set(url: @datocms_graphql_endpoint)
    Neuron.Config.set(headers: [authorization: "Bearer #{datocms_api_key}"])
    Neuron.Config.set(connection_opts: [timeout: :infinity, recv_timeout: :infinity])
    Neuron.Config.set(parse_options: [keys: :atoms])
  end

  def fetch_all(query, key, options \\ []) do
    skip = options[:skip] || 0
    first = options[:first] || @per_page
    {:ok, response} = Neuron.query(query, %{skip: skip, first: first})
    page = response.body[:data][key]
    case page do
      [] -> []
      _  -> page ++ fetch_all(query, key, Keyword.put(options, :skip, skip + first))
    end
  end
end
