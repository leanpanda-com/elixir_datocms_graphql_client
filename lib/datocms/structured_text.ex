defmodule DatoCMS.StructuredText do
  def to_html(%{value: %{schema: "dast", document: document}}) do
    render(document)
    |> Enum.join("")
  end

  defp render(%{type: "root"} = node) do
    Enum.map(node.children, &render/1)
  end

  defp render(%{type: "paragraph"} = node) do
    ["<p>" | [Enum.map(node.children, &render/1) | ["</p>"]]]
  end

  defp render(%{type: "span"} = node) do
    ["<span>" | [node.value | ["</span>"]]]
  end
end
