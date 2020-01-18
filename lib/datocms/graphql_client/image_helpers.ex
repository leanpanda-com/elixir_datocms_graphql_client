defmodule DatoCMS.GraphQLClient.ImageHelpers do
  @moduledoc """
  Documentation for DatoCMS.GraphQLClient.ImageHelpers.
  """

  def responsive_image_fragment do
    """
    srcSet
    webpSrcSet
    sizes
    src
    width
    height
    aspectRatio
    alt
    title
    bgColor
    base64
    """
  end
end
