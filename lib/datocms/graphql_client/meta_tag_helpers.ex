defmodule DatoCMS.GraphQLClient.MetaTagHelpers do
  def dato_meta_tags(%{_seoMetaTags: tags} = _item) do
    stringify_tags(tags)
  end

  def seo_meta_tags_fragment do
    """
    _seoMetaTags {
      attributes
      content
      tag
    }
    """
  end

  defp stringify_tags(tags) do
    Enum.map(tags, fn (tag) ->
      attributes = if tag[:attributes] do
          tag[:attributes]
          |> Enum.map(fn ({k, v}) -> "#{k}=\"#{v}\"" end)
          |> Enum.join(" ")
        else
          ""
        end
      if tag[:content] do
        "<#{tag.tag} #{attributes}>#{tag.content}</#{tag.tag}>"
      else
        "<#{tag.tag} #{attributes}/>"
      end
    end)
    |> Enum.join("\n")
  end
end
