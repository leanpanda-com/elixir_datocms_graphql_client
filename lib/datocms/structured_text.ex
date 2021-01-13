defmodule DatoCMS.StructuredText do
  @mark_nodes %{
    "code" => "code",
    "emphasis" => "em",
    "strikethrough" => "del",
    "strong" => "strong",
    "underline" => "u"
  }

  def to_html(%{value: %{schema: "dast", document: document}} = dast, options \\ %{}) do
    render(document, dast, options)
    |> Enum.join("")
  end

  def render(%{type: "root"} = node, dast, options) do
    Enum.map(node.children, &(render(&1, dast, options)))
  end

  def render(%{type: "paragraph"} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_paragraph] do
      renderers[:render_paragraph].(node, dast, options)
    else
      ["<p>" | [Enum.map(node.children, &(render(&1, dast, options))) | ["</p>"]]]
    end
  end

  def render(%{type: "heading"} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_heading] do
      renderers[:render_heading].(node, dast, options)
    else
      tag = "h#{node.level}"
      ["<#{tag}>" | [Enum.map(node.children, &(render(&1, dast, options))) | ["</#{tag}>"]]]
    end
  end

  def render(%{type: "link"} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_link] do
      renderers[:render_link].(node, dast, options)
    else
      [~s(<a href="#{node.url}">) | [Enum.map(node.children, &(render(&1, dast, options))) | ["</a>"]]]
    end
  end

  def render(%{type: "span", marks: ["highlight" | marks]} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_highlight] do
      renderers[:render_highlight].(node, dast, options)
    else
      simplified = Map.put(node, :marks, marks)
      ~s(<span class="highlight">) <> render(simplified, dast, options) <> "</span>"
    end
  end

  def render(%{type: "span", marks: [mark | marks]} = node, dast, options) do
    renderers = options[:renderers] || %{}
    renderer_key = :"render_#{mark}"
    if renderers[renderer_key] do
      renderers[renderer_key].(node, dast, options)
    else
      simplified = Map.put(node, :marks, marks)
      node = @mark_nodes[mark]
      "<#{node}>" <> render(simplified, dast, options) <> "</#{node}>"
    end
  end

  def render(%{type: "span"} = node, _dast, _options) do
    node.value
  end

  def render(
    %{type: "inlineItem"} = node,
    dast,
    %{renderers: %{render_inline_record: render_inline_record}}
  ) do
    item = Enum.find(dast.links, &(&1.id == node.item))
    render_inline_record.(item)
  end

  def render(
    %{type: "itemLink"} = node,
    dast,
    %{renderers: %{render_link_to_record: render_link_to_record}}
  ) do
    item = Enum.find(dast.links, &(&1.id == node.item))
    render_link_to_record.(item, node)
  end
end
