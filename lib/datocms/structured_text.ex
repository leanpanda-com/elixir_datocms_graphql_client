defmodule DatoCMS.StructuredText do
  def to_html(%{value: %{schema: "dast", document: document}} = dast, options \\ %{}) do
    render(document, dast, options)
    |> Enum.join("")
  end

  def render(%{type: "root"} = node, dast, options) do
    Enum.map(node.children, &(render(&1, dast, options)))
  end

  def render(
    %{type: "paragraph"} = node,
    dast,
    %{renderers: %{renderParagraph: renderParagraph}} = options
  ) do
    renderParagraph.(node, dast, options)
  end
  def render(%{type: "paragraph"} = node, dast, options) do
    ["<p>" | [Enum.map(node.children, &(render(&1, dast, options))) | ["</p>"]]]
  end

  def render(
    %{type: "heading"} = node,
    dast,
    %{renderers: %{renderHeading: renderHeading}} = options
  ) do
    renderHeading.(node, dast, options)
  end
  def render(%{type: "heading"} = node, dast, options) do
    tag = "h#{node.level}"
    ["<#{tag}>" | [Enum.map(node.children, &(render(&1, dast, options))) | ["</#{tag}>"]]]
  end

  def render(
    %{type: "link"} = node,
    dast,
    %{renderers: %{renderLink: renderLink}} = options
  ) do
    renderLink.(node, dast, options)
  end
  def render(%{type: "link"} = node, dast, options) do
    [~s(<a href="#{node.url}">) | [Enum.map(node.children, &(render(&1, dast, options))) | ["</a>"]]]
  end

  def render(%{type: "span"} = node, _dast, _options) do
    [render_span(node)]
  end

  def render(
    %{type: "inlineItem"} = node,
    dast,
    %{renderers: %{renderInlineRecord: renderInlineRecord}}
  ) do
    item = Enum.find(dast.links, &(&1.id == node.item))
    renderInlineRecord.(item)
  end

  def render(
    %{type: "itemLink"} = node,
    dast,
    %{renderers: %{renderLinkToRecord: renderLinkToRecord}}
  ) do
    item = Enum.find(dast.links, &(&1.id == node.item))
    renderLinkToRecord.(item, node)
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
