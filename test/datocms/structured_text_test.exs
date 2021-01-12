defmodule DatoCMS.StructuredTextTest do
  use ExUnit.Case, async: true
  import DatoCMS.Test.Support.FixtureHelper, only: [json_fixture!: 1]

  import DatoCMS.StructuredText, only: [to_html: 1]

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

  @tag structured_text: "Wrong!"
  test "the wrong structure", context do
    assert_raise FunctionClauseError, fn ->
      to_html(context.structured_text)
    end
  end
end
