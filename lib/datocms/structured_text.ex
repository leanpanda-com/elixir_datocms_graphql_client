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

  def render(%{type: "blockquote"} = node, dast, options) do
    render_blockquote = get_in(options, [:renderers, :render_blockquote])
    if render_blockquote do
      render_blockquote.(node, dast, options) |> list()
    else
      caption = if Map.has_key?(node, :attribution) do
        ["<figcaption>— #{node.attribution}</figcaption>"]
      else
        []
      end

      ["<figure>"] ++
        ["<blockquote>"] ++
        Enum.flat_map(node.children, &(render(&1, dast, options))) ++
        ["</blockquote>"] ++
        caption ++
        ["</figure>"]
    end
  end

  def render(%{type: "code", code: code} = node, dast, options) do
    render_code = get_in(options, [:renderers, :render_code])
    if render_code do
      render_code.(node, dast, options) |> list()
    else
      ["<code>", code, "</code>"]
    end
  end

  def render(%{type: "list", style: "bulleted"} = node, dast, options) do
    render_bulleted_list = get_in(options, [:renderers, :render_bulleted_list])
    if render_bulleted_list do
      render_bulleted_list.(node, dast, options) |> list()
    else
      ["<ul>"] ++
        Enum.flat_map(
          node.children,
          fn list_item ->
            ["<li>"] ++
              Enum.flat_map(list_item.children, &(render(&1, dast, options))) ++
              ["</li>"]
          end
        ) ++
        ["</ul>"]
    end
  end

  def render(%{type: "list", style: "numbered"} = node, dast, options) do
    render_numbered_list = get_in(options, [:renderers, :render_numbered_list])
    if render_numbered_list do
      render_numbered_list.(node, dast, options) |> list()
    else
      ["<ol>"] ++
        Enum.flat_map(
          node.children,
          fn list_item ->
            ["<li>"] ++
              Enum.flat_map(list_item.children, &(render(&1, dast, options))) ++
              ["</li>"]
          end
        ) ++
        ["</ol>"]
    end
  end

  def render(%{type: "paragraph"} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_paragraph] do
      renderers[:render_paragraph].(node, dast, options) |> list()
    else
      inner = Enum.flat_map(node.children, &(render(&1, dast, options)))
      ["<p>"] ++ inner ++ ["</p>"]
    end
  end

  def render(%{type: "heading"} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_heading] do
      renderers[:render_heading].(node, dast, options) |> list()
    else
      tag = "h#{node.level}"
      inner = Enum.flat_map(node.children, &(render(&1, dast, options)))
      ["<#{tag}>"] ++ inner ++ ["</#{tag}>"]
    end
  end

  def render(%{type: "link"} = node, dast, options) do
    renderers = options[:renderers] || %{}
    if renderers[:render_link] do
      renderers[:render_link].(node, dast, options) |> list()
    else
      inner = Enum.flat_map(node.children, &(render(&1, dast, options)))
      [~s(<a href="#{node.url}">)] ++ inner ++ ["</a>"]
    end
  end

  def render(%{type: "span", marks: [mark | marks]} = node, dast, options) do
    renderers = options[:renderers] || %{}
    renderer_key = :"render_#{mark}"
    if renderers[renderer_key] do
      renderers[renderer_key].(node, dast, options) |> list()
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

  def render(%{type: "inlineItem"} = node, dast, options) do
    with {:ok, renderer} <- renderer(options, :render_inline_record),
         {:ok, item} <- linked_item(node, dast) do
      renderer.(item) |> list()
    else
      {:error, message} ->
        raise CustomRenderersError, message: message
    end
  end

  def render(%{type: "itemLink"} = node, dast, options) do
    with {:ok, renderer} <- renderer(options, :render_link_to_record),
         {:ok, item} <- linked_item(node, dast) do
      renderer.(item, node) |> list()
    else
      {:error, message} ->
        raise CustomRenderersError, message: message
    end
  end

  def render(%{type: "block"} = node, dast, options) do
    with {:ok, renderer} <- renderer(options, :render_block),
         {:ok, item} <- block(node, dast) do
      renderer.(item) |> list()
    else
      {:error, message} ->
        raise CustomRenderersError, message: message
    end
  end

  defp renderer(%{renderers: renderers}, name) do
    renderer = renderers[name]
    if renderer do
      {:ok, renderer}
    else
      {
        :error,
        """
        No `#{name}` function supplied in options.renders

        Supplied renderers:
        #{inspect(Map.keys(renderers))}
        """
      }
    end
  end
  defp renderer(options, _name) do
    {
      :error,
      """
      No `:renderers` supplied in options:

      options: #{inspect(Map.keys(options))}
      """
    }
  end

  defp block(%{item: item_id} = node, %{blocks: blocks}) do
    item = Enum.find(blocks, &(&1.id == item_id))
    if item do
      {:ok, item}
    else
    {
      :error,
      """
      Linked item `#{item_id}` not found in `dast.blocks`.

      A "block" node requires item #{node.item} to be present in `dast.blocks`.

      `node` contents:
      #{inspect(node)}

      `links` contents:
      #{inspect(blocks)}
      """
    }
    end
  end
  defp block(node, dast) do
    {
      :error,
      """
      No `:blocks` supplied in dast.

      A "block" node requires `:blocks` to be present in `dast`.

      `node` contents:
      #{inspect(node)}

      `dast` contents:
      #{inspect(dast)}
      """
    }
  end

  defp linked_item(%{item: item_id} = node, %{links: links}) do
    item = Enum.find(links, &(&1.id == item_id))
    if item do
      {:ok, item}
    else
    {
      :error,
      """
      Linked item `#{item_id}` not found in `dast.links`.

      A node of type `#{node.type}` requires item #{node.item} to be present in the `dast`.

      `node` contents:
      #{inspect(node)}

      `links` contents:
      #{inspect(links)}
      """
    }
    end
  end
  defp linked_item(node, dast) do
    {
      :error,
      """
      No `:links` supplied in dast.

      A node of type `#{node.type}` requires `:links` to be present in the `dast`.

      `node` contents:
      #{inspect(node)}

      `dast` contents:
      #{inspect(dast)}
      """
    }
  end

  defp list(item) when is_list(item), do: item
  defp list(item), do: [item]
end
