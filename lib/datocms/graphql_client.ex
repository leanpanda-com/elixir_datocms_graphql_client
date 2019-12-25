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

  def fetch_all!(query, key, options \\ []) do
    {:ok, pages} = fetch_all(query, key, options)
    pages
  end

  def fetch_all(query, key, options \\ []) do
    paginated = """
      query paginated($first: IntType!, $skip: IntType!) {
        #{key}(first: $first, skip: $skip) #{query}
      }
    """
    skip = options[:skip] || 0
    first = options[:first] || @per_page
    do_fetch_all(paginated, key, [skip: skip, first: first])
  end

  defp do_fetch_all(paginated, key, options) do
    skip = options[:skip]
    first = options[:first]
    {:ok, response} = Neuron.query(paginated, %{skip: skip, first: first})
    handle_fetch_all_response(response.body, paginated, key, options)
  end

  defp handle_fetch_all_response(%{errors: errors} = body, _paginated, _key, _options), do: {:error, errors}
  defp handle_fetch_all_response(body, paginated, key, options) do
    page = body[:data][key]
    case page do
      [] -> {:ok, []}
      _  ->
        skip = options[:skip]
        first = options[:first]
        {:ok, pages} = do_fetch_all(paginated, key, Keyword.put(options, :skip, skip + first))
        {:ok, page ++ pages}
    end
  end
end
