import gleam/bit_builder.{BitBuilder}
import gleam/http/service.{Service}
import gleam/http/request.{Request}
import gleam/http/response
import gleam/http
import gleam/function
import gleam/pgo
import todomvc/templates/home as home_template
import todomvc/templates/item_created as item_created_template
import todomvc/templates/item_deleted as item_deleted_template
import todomvc/item.{Item}
import todomvc/error
import todomvc/web
import todomvc/web/static
import todomvc/web/print_requests

pub fn router(request: Request(BitString), db: pgo.Connection) -> web.Result {
  case request.path_segments(request) {
    [] -> home(All)
    ["active"] -> home(Active)
    ["completed"] -> completed(request)
    ["todos"] -> todos(request)
    ["todos", id] -> todo_item(request, id)
    _ -> Error(error.NotFound)
  }
}

pub fn stack(db: pgo.Connection) -> Service(BitString, BitBuilder) {
  router(_, db)
  |> function.compose(web.result_to_response)
  |> service.prepend_response_header("made-with", "Gleam")
  |> service.map_response_body(bit_builder.from_string_builder)
  |> print_requests.middleware
  |> static.middleware()
}

pub type ItemsCategory {
  All
  Active
  Completed
}

fn home(_category: ItemsCategory) -> web.Result {
  let items = [
    Item(id: 1, completed: True, content: "Create Gleam"),
    Item(id: 2, completed: False, content: "Write TodoMVC in Gleam"),
    Item(id: 3, completed: False, content: "Deploy TodoMVC"),
    Item(id: 4, completed: False, content: "<script>alert(1)</script>"),
  ]

  home_template.render_builder(items)
  |> web.html_response(200)
  |> Ok
}

fn completed(request: Request(BitString)) -> web.Result {
  case request.method {
    http.Get -> home(Completed)
    http.Delete -> todo
    _ -> Error(error.MethodNotAllowed)
  }
}

fn todos(request: Request(BitString)) -> web.Result {
  case request.method {
    http.Post -> create_todo(request)
    _ -> Error(error.MethodNotAllowed)
  }
}

fn create_todo(_request: Request(BitString)) -> web.Result {
  // TODO: create item
  let item = Item(id: 5, completed: False, content: "wibble")
  item_created_template.render_builder(
    item: item,
    // TODO: count
    completed_count: 5,
    // TODO: count
    remaining_count: 10,
    // TODO: count
    can_clear_completed: True,
  )
  |> web.html_response(201)
  |> Ok
}

fn todo_item(request: Request(BitString), id: String) -> web.Result {
  case request.method {
    http.Get -> todo
    http.Delete -> delete_item(request, id)
    http.Put -> todo
    _ -> Error(error.MethodNotAllowed)
  }
}

fn delete_item(_request: Request(BitString), _id: String) -> web.Result {
  // TODO: delete item
  item_deleted_template.render_builder(
    // TODO: count
    completed_count: 4,
    // TODO: count
    remaining_count: 9,
    // TODO: count
    can_clear_completed: True,
  )
  |> web.html_response(200)
  |> Ok
}
