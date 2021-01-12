defmodule DatoCMS.StructuredTextTest do
  use ExUnit.Case, async: true
  import DatoCMS.StructuredText, only: [to_html: 1]

  setup do
    [
      structured_text: %{
        value: %{
          schema: "dast",
          document: %{
            type: "root",
            children: [
              %{
                type: "paragraph",
                children: [
                  %{
                    type: "span",
                    value: "Hi There"
                  }
                ]
              }
            ]
          }
        }
      }
    ]
  end

  test "it renders as HTML", context do
    result = to_html(context.structured_text)
    expected = "<p><span>Hi There</span></p>"
    assert(result == expected)
  end

  test "when the wrong structure is passed, it fails" do
    assert_raise FunctionClauseError, fn ->
      to_html("wrong!")
    end
  end
end
