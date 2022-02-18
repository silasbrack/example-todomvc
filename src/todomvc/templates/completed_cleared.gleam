import gleam/string_builder.{StringBuilder}
import gleam/list
import todomvc/templates/item as item_template
import todomvc/item.{Counts, Item}
import gleam/int

pub fn render_builder(
  items items: List(Item),
  counts counts: Counts,
) -> StringBuilder {
  let builder = string_builder.from_string("")
  let builder =
    string_builder.append(
      builder,
      "

<ul hx-swap-oob=\"innerHTML\" id=\"todo-list\">
  ",
    )
  let builder =
    list.fold(
      items,
      builder,
      fn(builder, item: Item) {
        let builder = string_builder.append(builder, "
  ")
        let builder =
          string_builder.append_builder(
            builder,
            item_template.render_builder(item, False),
          )
        let builder = string_builder.append(builder, "
  ")

        builder
      },
    )
  let builder =
    string_builder.append(
      builder,
      "
</ul>

<span hx-swap-oob=\"innerHTML\" id=\"todo-count\">
  <strong>",
    )
  let builder = string_builder.append(builder, int.to_string(counts.active))
  let builder = string_builder.append(builder, "</strong> todos left
</span>
")

  builder
}

pub fn render(items items: List(Item), counts counts: Counts) -> String {
  string_builder.to_string(render_builder(items: items, counts: counts))
}
