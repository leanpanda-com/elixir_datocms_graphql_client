defmodule DatoCMS.GraphqlClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :datocms_graphql_client,
      version: "0.10.0",
      elixir: "~> 1.9",
      description: "Helpers for DatoCMS GraphQL access",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{
        "GitLab" => "https://github.com/leanpanda-com/datocms_graphql_client"
      },
      maintainers: ["Joe Yates"]
    }
  end

  defp deps do
    [
      {:ex_doc, "~> 0.21.2", only: :dev},
      {:neuron, "~> 4.1.0"}
    ]
  end
end
