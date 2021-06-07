defmodule DatoCMS.GraphQLClient.Backends.StandardClient do
  @moduledoc """
  A basic client for DatoCMS GraphQL requests
  """

  @endpoint "https://graphql.datocms.com/"
  @per_page 100

  def configure(options \\ []) do
    config = configuration(options)

    if Keyword.has_key?(config, :endpoint) do
      endpoint = config[:endpoint]
      Neuron.Config.set(url: endpoint)
    end

    if Keyword.has_key?(config, :api_key) do
      api_key = config[:api_key]
      Neuron.Config.set(headers: [authorization: "Bearer #{api_key}"])
    else
      raise "Please set the `api_key` configuration option"
    end

    Neuron.Config.set(connection_opts: [timeout: :infinity, recv_timeout: :infinity])
    Neuron.Config.set(parse_options: [keys: :atoms])
  end

  def configuration(options \\ []) do
    config_defaults = Application.get_env(:datocms_graphql_client, :config, [])
    defaults = Keyword.merge([endpoint: @endpoint], config_defaults)
    Keyword.merge(defaults, options)
  end

  def live? do
    configuration()[:live]
  end

  def query(query, params \\ %{}) do
    Neuron.query(query, params)
    |> handle_response()
  end

  def query!(query, params \\ %{}) do
    case query(query, params) do
      {:ok, page} -> page
      {:error, error} ->
        raise """
          GraphQL query '#{query}':
          params: #{inspect(params)}
          error: #{inspect(error)}
        """
    end
  end

  def fetch!(key, query, params \\ %{}) do
    case fetch(key, query, params) do
      {:ok, page} -> page
      {:error, error} ->
        raise """
          GraphQL query #{key} '#{query}':
          params: #{inspect(params)}
          error: #{inspect(error)}
        """
    end
  end

  def fetch(key, query_body, params \\ %{}) do
    keyed = fetch_query(key, query_body)
    result = query(keyed, params)

    case result do
      {:ok, data} -> {:ok, data[key]}
      other -> other
    end
  end

  def fetch_query(key, query), do: "query { #{key} #{query} }"

  def fetch_localized!(key, locale, query, params \\ %{}) do
    case fetch_localized(key, locale, query, params) do
      {:ok, page} -> page
      {:error, error} ->
        raise """
          GraphQL query '#{key}':
          '#{query}'
          locale: '#{locale}'
          params: #{inspect(params)}
          error: #{inspect(error)}
        """
    end
  end

  def fetch_localized(key, locale, query, params \\ %{}) do
    keyed = """
      query FetchLocalized($locale: SiteLocale!) {
        #{key}(locale: $locale) #{query}
      }
    """
    with_locale = with_locale(params, locale)

    result = Neuron.query(keyed, with_locale)
    |> handle_response()

    case result do
      {:ok, data} -> data[key]
      other -> other
    end
  end

  def fetch_all!(key, query, params \\ %{}) do
    case fetch_all(key, query, params) do
      {:ok, pages} -> pages
      {:error, error} ->
        raise """
          GraphQL query '#{key}':
          '#{query}'
          params: #{inspect(params)}
          error: #{inspect(error)}
        """
    end
  end

  def fetch_all(key, query, params \\ %{}) do
    paginated = """
      query paginated($first: IntType!, $skip: IntType!) {
        #{key}(first: $first, skip: $skip) #{query}
      }
    """
    do_fetch_all(key, paginated, with_default_pagination(params))
  end

  def fetch_all_localized!(key, locale, query, params \\ %{}) do
    case fetch_all_localized(key, locale, query, params) do
      {:ok, pages} -> pages
      {:error, error} ->
        raise """
          GraphQL query '#{key}':
          '#{query}'
          locale: '#{locale}'
          params: #{inspect(params)}
          error: #{inspect(error)}
        """
    end
  end

  def fetch_all_localized(key, locale, query, params \\ %{}) do
    paginated = """
      query paginated($locale: SiteLocale!, $first: IntType!, $skip: IntType!) {
        #{key}(locale: $locale, first: $first, skip: $skip) #{query}
      }
    """
    do_fetch_all(key, paginated, with_locale(with_default_pagination(params), locale))
  end

  def do_fetch_all(key, paginated, params) do
    Neuron.query(paginated, params)
    |> handle_fetch_all_query(key, paginated, params)
  end

  defp handle_response({:error, %HTTPoison.Error{id: nil, reason: :nxdomain}}) do
    {:error, "Cannot resolve domain"}
  end
  defp handle_response({:error, %Neuron.Response{body: %{data: data}}}) do
    {:error, "Request failed: #{inspect(data)}"}
  end
  defp handle_response({:ok, %Neuron.Response{body: %{errors: errors}}}) do
    {:error, errors}
  end
  defp handle_response({:ok, %Neuron.Response{body: %{data: data}}}) do
    {:ok, data}
  end
  defp handle_response({:ok, %Neuron.Response{body: %{url: url}}}) do
    {:ok, url}
  end

  defp handle_fetch_all_query({:error, _errors} = response, _key, _paginated, _params), do: response
  defp handle_fetch_all_query({:ok, response}, key, paginated, params) do
    handle_fetch_all_response(response.body, key, paginated, params)
  end

  defp handle_fetch_all_response(%{errors: errors} = _body, _key, _paginated, _params) do
    {:error, errors}
  end
  defp handle_fetch_all_response(body, key, paginated, params) do
    page = body[:data][key]
    case page do
      [] -> {:ok, []}
      _  ->
        params = Map.put(params, :skip, params.skip + params.first)
        {:ok, pages} = do_fetch_all(key, paginated, params)
        {:ok, page ++ pages}
    end
  end

  defp with_default_pagination(params) do
    skip = params[:skip] || 0
    first = params[:first] || @per_page
    params
      |> Map.put(:skip, skip)
      |> Map.put(:first, first)
  end

  defp with_locale(params, locale), do: Map.put(params, :locale, locale)
end
