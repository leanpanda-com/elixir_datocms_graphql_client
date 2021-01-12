defmodule DatoCMS.StructuredText do
  def to_html(%{value: %{schema: "dast", document: document}} = dast, options \\ %{}) do
    render(document, dast, options)
    |> Enum.join("")
  end

  defp render(%{type: "root"} = node, dast, options) do
    Enum.map(node.children, &(render(&1, dast, options)))
  end

  defp render(%{type: "paragraph"} = node, dast, options) do
    ["<p>" | [Enum.map(node.children, &(render(&1, dast, options))) | ["</p>"]]]
  end

  defp render(%{type: "heading"} = node, dast, options) do
    tag = "h#{node.level}"
    ["<#{tag}>" | [Enum.map(node.children, &(render(&1, dast, options))) | ["</#{tag}>"]]]
  end

  defp render(%{type: "link"} = node, dast, options) do
    [~s(<a href="#{node.url}">) | [Enum.map(node.children, &(render(&1, dast, options))) | ["</a>"]]]
  end

  defp render(%{type: "span"} = node, _dast, _options) do
    [render_span(node)]
  end

  defp render(
    %{type: "inlineItem"} = node,
    dast,
    %{renderers: %{renderInlineRecord: renderInlineRecord}} = options
  ) do
    renderInlineRecord.(node, dast, options)
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
