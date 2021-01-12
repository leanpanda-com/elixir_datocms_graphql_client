defmodule DatoCMS.StructuredTextTest do
  use ExUnit.Case, async: true
  import DatoCMS.Test.Support.FixtureHelper, only: [json_fixture!: 1]

  import DatoCMS.StructuredText, only: [to_html: 1]

  @tag structured_text: json_fixture!("minimal-text")
  test "it renders as HTML", context do
    result = to_html(context.structured_text)
    expected = "<p><span>Hi There</span></p>"
    assert(result == expected)
  end

  @tag structured_text: "Wrong!"
  test "when the wrong structure is passed, it fails", context do
    assert_raise FunctionClauseError, fn ->
      to_html(context.structured_text)
    end
  end
end
