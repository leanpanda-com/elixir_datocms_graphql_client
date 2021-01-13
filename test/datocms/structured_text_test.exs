defmodule DatoCMS.StructuredTextTest do
  use ExUnit.Case, async: true
  import DatoCMS.Test.Support.FixtureHelper, only: [json_fixture!: 1]

  import DatoCMS.StructuredText, only: [
    to_html: 1,
    to_html: 2,
    render: 3,
    render_span: 3
  ]

  def render_inline_record(%{__typename: "ItemRecord"} = item) do
    "<h1>#{item.title}</h1><p>#{item.body}</p>"
  end

  def render_link_to_record(%{__typename: "ItemRecord"} = item, node) do
    ~s(<a href="/items/#{item.id}">#{hd(node.children).value}</a>)
  end

  def render_custom_heading(node, dast, options) do
    tag = "h#{node.level + 1}"
    ["<#{tag}>" | [Enum.map(node.children, &(render(&1, dast, options))) | ["</#{tag}>"]]]
  end

  def render_custom_paragraph(node, dast, options) do
    ["<div>" | [Enum.map(node.children, &(render(&1, dast, options))) | ["</div>"]]]
  end

  def render_custom_link(node, dast, options) do
    [~s(<a href="#{node.url}" class="button">) | [Enum.map(node.children, &(render(&1, dast, options))) | ["</a>"]]]
  end

  def render_custom_highlights(%{marks: ["highlight" | marks]} = span, dast, options) do
    simplified = Map.put(span, :marks, marks)
    ~s(<span class="bright>) <> render_span(simplified, dast, options) <> "</span>"
  end

  @tag structured_text: json_fixture!("minimal-text")
  test "minimal text", context do
    result = to_html(context.structured_text)

    expected = "<p>Hi There</p>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("minimal-text")
  test "custom paragraph renderer", context do
    options = %{renderers: %{render_paragraph: &render_custom_paragraph/3}}
    result = to_html(context.structured_text, options)

    expected = "<div>Hi There</div>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("headings")
  test "headings", context do
    result = to_html(context.structured_text)

    expected = "<h1>The Title!!!</h1>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("headings")
  test "custom heading renderer", context do
    options = %{renderers: %{render_heading: &render_custom_heading/3}}
    result = to_html(context.structured_text, options)

    expected = "<h2>The Title!!!</h2>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("links")
  test "links", context do
    result = to_html(context.structured_text)

    expected = "<p><a href=\"https://example.com\">Link</a></p>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("links")
  test "custom link renderer", context do
    options = %{renderers: %{render_link: &render_custom_link/3}}
    result = to_html(context.structured_text, options)

    expected = ~s(<p><a href="https://example.com" class="button">Link</a></p>)
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("text-styles")
  test "text styles", context do
    result = to_html(context.structured_text)

    expected =
      "<p>" <>
      "<strong><span class=\"highlight\">Some</span></strong> " <>
      "styled " <>
      "<em>text</em> " <>
      "<span class=\"highlight\">including</span> " <>
      "<code>integers</code>, " <>
      "<del>cancelled words</del>, and " <>
      "<u>underlined</u> things." <>
      "</p>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("text-styles")
  test "custom highlights", context do
    options = %{renderers: %{render_highlight: &render_custom_highlights/3}}
    result = to_html(context.structured_text, options)

    expected = ~s(<span class="bright>Some</span>)
    assert(String.contains?(result, expected))
  end

  @tag structured_text: json_fixture!("inline-item")
  test "inlineItem", context do
    options = %{renderers: %{render_inline_record: &render_inline_record/1}}
    result = to_html(context.structured_text, options)

    expected = "<p><h1>The item title</h1><p>The body</p></p>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("inline-item")
  test "inlineItem without render_inline_record", context do
    assert_raise FunctionClauseError, fn ->
      to_html(context.structured_text)
    end
  end

  @tag structured_text: json_fixture!("item-link")
  test "itemLink", context do
    options = %{renderers: %{render_link_to_record: &render_link_to_record/2}}
    result = to_html(context.structured_text, options)

    expected = "<p>A <a href=\"/items/15236536\">link</a> to an item.</p>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("item-link")
  test "itemLink without render_link_to_record", context do
    assert_raise FunctionClauseError, fn ->
      to_html(context.structured_text)
    end
  end

  @tag structured_text: "Wrong!"
  test "the wrong structure", context do
    assert_raise FunctionClauseError, fn ->
      to_html(context.structured_text)
    end
  end
end
