defmodule DatoCMS.StructuredText do
  defmodule CustomRenderersError do
    defexception [:message]
  end

  @mark_nodes %{
    "code" => "code",
    "emphasis" => "em",
    "highlight" => "mark",
    "strikethrough" => "del",
    "strong" => "strong",
    "underline" => "u"
  }

  def to_html(
    %{value: %{schema: "dast", document: document}} = dast, options \\ %{}
  ) do
    render(document, dast, options)
    |> Enum.join("")
  end

  def render(%{type: "root"} = node, dast, options) do
    Enum.flat_map(node.children, &(render(&1, dast, options)))
  end

  def render(%{type: "paragraph"} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_paragraph] do
      renderers[:render_paragraph].(node, dast, options)
    else
      inner = Enum.flat_map(node.children, &(render(&1, dast, options)))
      ["<p>"] ++ inner ++ ["</p>"]
    end
  end

  def render(%{type: "heading"} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_heading] do
      renderers[:render_heading].(node, dast, options)
    else
      tag = "h#{node.level}"
      inner = Enum.flat_map(node.children, &(render(&1, dast, options)))
      ["<#{tag}>"] ++ inner ++ ["</#{tag}>"]
    end
  end

  def render(%{type: "link"} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_link] do
      renderers[:render_link].(node, dast, options)
    else
      inner = Enum.flat_map(node.children, &(render(&1, dast, options)))
      [~s(<a href="#{node.url}">)] ++ inner ++ ["</a>"]
    end
  end

  def render(%{type: "span", marks: [mark | marks]} = node, dast, options) do
    renderers = options[:renderers] || %{}
    renderer_key = :"render_#{mark}"
    if renderers[renderer_key] do
      renderers[renderer_key].(node, dast, options)
    else
      simplified = Map.put(node, :marks, marks)
      inner = render(simplified, dast, options)
      node = @mark_nodes[mark]
      ["<#{node}>"] ++ inner ++ ["</#{node}>"]
    end
  end

  def render(%{type: "span"} = node, _dast, _options) do
    [node.value]
  end

  def render(
    %{type: "inlineItem"} = node,
    dast,
    %{renderers: %{render_inline_record: render_inline_record}}
  ) do
    item = Enum.find(dast.links, &(&1.id == node.item))
    render_inline_record.(item)
  end
  def render(%{type: "inlineItem"} = _node, _dast, %{renderers: renderers}) do
    message = """
    No `render_inline_record/1` function supplied.
    Renderers supplied via options: #{inspect(Map.keys(renderers))}
    """
    raise CustomRenderersError, message: message
  end
  def render(%{type: "inlineItem"} = _node, _dast, _options) do
    message = """
    No `render_inline_record/1` function supplied via options.
    """
    raise CustomRenderersError, message: message
  end

  def render(
    %{type: "itemLink"} = node,
    dast,
    %{renderers: %{render_link_to_record: render_link_to_record}}
  ) do
    item = Enum.find(dast.links, &(&1.id == node.item))
    render_link_to_record.(item, node)
  end
  def render(%{type: "itemLink"} = _node, _dast, %{renderers: renderers}) do
    message = """
    No `render_link_to_record/2` function supplied.
    Renderers supplied via options: #{inspect(Map.keys(renderers))}
    """
    raise CustomRenderersError, message: message
  end
  def render(%{type: "itemLink"} = _node, _dast, _options) do
    message = """
    No `render_link_to_record/2` function supplied.
    """
    raise CustomRenderersError, message: message
  end

  def render(
    %{type: "block"} = node,
    dast,
    %{renderers: %{render_block: render_block}}
  ) do
    block = Enum.find(dast.blocks, &(&1.id == node.item))
    render_block.(block)
  end
  def render(%{type: "block"} = _node, _dast, %{renderers: renderers}) do
    message = """
    No `render_block/1` function supplied.
    Renderers supplied via options: #{inspect(Map.keys(renderers))}
    """
    raise CustomRenderersError, message: message
  end
  def render(%{type: "block"} = _node, _dast, _options) do
    message = """
    No `render_block/1` function supplied.
    """
    raise CustomRenderersError, message: message
  end
end
