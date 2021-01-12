defmodule DatoCMS.StructuredTextTest do
  use ExUnit.Case, async: true
  import DatoCMS.Test.Support.FixtureHelper, only: [json_fixture!: 1]

  import DatoCMS.StructuredText, only: [
    to_html: 1,
    to_html: 2
  ]

  def renderInlineRecord(%{type: "inlineItem", item: id}, dast, _options) do
    node = Enum.find(dast.links, &(&1.id == id))
    renderRecord(node)
  end

  def renderRecord(%{__typename: "ItemRecord"} = node) do
    "<h1>#{node.title}</h1><p>#{node.body}</p>"
  end

  @tag structured_text: json_fixture!("minimal-text")
  test "simple text", context do
    result = to_html(context.structured_text)

    expected = "<p>Hi There</p>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("headings")
  test "headings", context do
    result = to_html(context.structured_text)

    expected = "<h1>The Title!!!</h1>"
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
      "<u>underlined</u> things. See " <>
      "<a href=\"https://example.com\">here</a>." <>
      "</p>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("inline-item")
  test "inlineItem", context do
    options = %{renderers: %{renderInlineRecord: &renderInlineRecord/3}}
    result = to_html(context.structured_text, options)

    expected = "<p><h1>The item title</h1><p>The body</p></p>"
    assert(result == expected)
  end

  @tag structured_text: json_fixture!("inline-item")
  test "inlineItem without renderInlineRecord", context do
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
