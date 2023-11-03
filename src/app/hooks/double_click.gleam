import gleam/option.{Some}
import sprocket/context.{Context}
import sprocket/hooks/client.{client}

// Custom hook for handling to client double click events
pub fn double_click(ctx: Context, on_double_click: fn() -> Nil, cb) {
  use ctx, client_doubleclick, _client_doubleclick_dispatch <- client(
    ctx,
    "DoubleClick",
    Some(fn(msg, _payload, _dispatch) {
      case msg {
        "doubleclick" -> {
          on_double_click()
        }
        _ -> Nil
      }
    }),
  )

  cb(ctx, client_doubleclick)
}
