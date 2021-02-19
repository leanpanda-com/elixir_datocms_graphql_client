# DatoCMS GraphQL Client

# Initialization

In config/config.exs:

```elixir
config :my_app,
  api_key: System.get_env("DATOCMS_API_KEY")
```

```elixir
datocms_api_key = Application.fetch_env!(:my_app, :api_key)
DatoCMS.GraphQLClient.config(api_key: datocms_api_key)
```

# Queries

* single items: `DatoCMS.GraphQLClient.fetch!(:foo, "{ bar }").bar`,
* localized single items: `DatoCMS.GraphQLClient.fetch_localized!(:foo, :en, "{ bar }")`,
* collections: `DatoCMS.GraphQLClient.fetch_all!(:allFoos, "{ bar }")`,
* localized collections: `DatoCMS.GraphQLClient.fetch_all_localized!(:allFoos, :en, "{ bar }")`.

# Structured Text

DatoCMS structured text fields are complex, and rendering them
as HTML is hard.

This library provides the helper `DatoCMS.StructuredText.to_html/2`,
which takes the structured text part of a GraphQL response and
transforms it into HTML.

The default rendering turns this:

```json
{
  "value": {
    "schema": "dast",
    "document": {
      "type": "root",
      "children": [
        {
          "type": "paragraph",
          "children": [
            {
              "type": "span",
              "value": "Hi There"
            }
          ]
        }
      ]
    }
  }
}
```

with this:

```elixir
DatoCMS.StructuredText.to_html(structured_text)
```

into this:

```html
<p>Hi There</p>
```

By default, the types are transformed as follows:

| type       | result                                |
|------------|---------------------------------------|
| root       | the rendered children                 |
| paragraph  | `<p>...</p>`                          |
| span       | the node value                        |
| heading    | `<hn>...</hn>` where `n` is the level |
| link       | `<a ...>...</a>`                      |
| block      | requires custom renderer (see below)  |
| inlineItem | requires custom renderer (see below)  |
| itemLink   | requires custom renderer (see below)  |

Note that text styling is transformed as follows:

| mark          | tag    |
|---------------|--------|
| code          | code   |
| emphasis      | em     |
| highlight     | mark   |
| strikethrough | del    |
| strong        | strong |
| underline     | u      |

## Optional Custom Renderers

All of these types of rendering can be overriden.

This is achieved by passing custom renderers in the second `options`
parameter:

```elixir
import DatoCMS.StructuredText, only: [to_html: 2, render: 3]

def custom_paragraph(node, _dast, _options) do
  ["<section>"] ++
    Enum.map(node.children, &(render(&1, dast, options))) ++
    ["</section>"]
end

options = %{
  renderers: %{
    render_paragraph: &custom_paragraph/3
  }
}

result = to_html(structured_text, options)
```

Note: custom renderers need to return a `list` of strings.

The custom renderers that can be used in this way are the following:

* `render_paragraph/3`,
* `render_heading/3`,
* `render_link/3`,
* `render_highlight/3`,
* `render_code/3`,
* `render_emphasis/3`,
* `render_strikethrough/3`,
* `render_strong/3`,
* `render_underline/3`,
* `render_span/3`.

## Required Renderers

If your structured text includes blocks, inline items
or item links, you'll need to supply a custom renderer.

* `render_block/1` for blocks,
* `render_inline_record/1` for inline items,
* `render_link_to_record/2` for item links.
