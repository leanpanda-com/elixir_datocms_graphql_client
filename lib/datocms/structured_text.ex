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

  defp render(%{type: "heading"} = node) do
    tag = "h#{node.level}"
    ["<#{tag}>" | [Enum.map(node.children, &render/1) | ["</#{tag}>"]]]
  end

  defp render(%{type: "link"} = node) do
    [~s(<a href="#{node.url}">) | [Enum.map(node.children, &render/1) | ["</a>"]]]
  end

  defp render(%{type: "span"} = node) do
    [render_span(node)]
  end

  defp render_span(%{marks: ["highlight" | marks]} = span) do
    simplified = Map.put(span, :marks, marks)
    ~s(<span class="highlight">) <> render_span(simplified) <> "</span>"
  end

  @mark_nodes %{
    "code" => "code",
    "emphasis" => "em",
    "strikethrough" => "del",
    "strong" => "strong",
    "underline" => "u"
  }

  defp render_span(%{marks: [mark | marks]} = span) do
    simplified = Map.put(span, :marks, marks)
    node = @mark_nodes[mark]
    "<#{node}>" <> render_span(simplified) <> "</#{node}>"
  end

  defp render_span(%{marks: []} = span) do
    span.value
  end

  defp render_span(span) do
    span.value
  end
end
