import gleam/io
import gleam/option.{None}
import gleam/list
import gleam/bit_array
import gleam/bytes_builder.{type BytesBuilder}
import gleam/otp/actor
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import ids/uuid
import mist.{type Connection, type ResponseData}
import sprocket
import sprocket/cassette.{type Cassette}
import sprocket/render.{render}
import sprocket/component.{component}
import sprocket/html/render as html_render
import sprocket/context.{type FunctionalComponent}
import sprocket/internal/logger

pub fn live(
  req: Request(Connection),
  ca: Cassette,
  view: FunctionalComponent(p),
  props: p,
) -> Response(ResponseData) {
  let view = component(view, props)

  // if the request path ends with "live", then start a websocket connection
  case list.last(request.path_segments(req)) {
    Ok("live") -> {
      let assert Ok(id) = uuid.generate_v4()

      req
      |> mist.websocket(
        fn(state, conn, message) {
          handle_ws_message(id, state, conn, message, ca, view)
        },
        fn() { #(Nil, None) },
        fn(_) { sprocket.cleanup(ca, id) },
      )
    }

    _ -> {
      let body = render(view, html_render.renderer())

      response.new(200)
      |> response.set_body(body)
      |> response.prepend_header("content-type", "text/html")
      |> response.map(bytes_builder.from_string)
      |> mist_response()
    }
  }
}

fn mist_response(response: Response(BytesBuilder)) -> Response(ResponseData) {
  response.new(response.status)
  |> response.set_body(mist.Bytes(response.body))
}

fn handle_ws_message(id: String, state: Nil, conn, message, ca, view) {
  let ws_send = fn(msg) {
    case mist.send_text_frame(conn, bit_array.from_string(msg)) {
      Ok(_) -> Ok(Nil)
      Error(_) -> {
        logger.error("failed to send websocket message: " <> msg)
        Ok(Nil)
      }
    }
  }

  case message {
    mist.Text(msg) -> {
      let assert Ok(msg) = bit_array.to_string(msg)

      let _ = sprocket.handle_client(id, ca, view, msg, ws_send)

      actor.continue(state)
    }

    mist.Closed | mist.Shutdown -> {
      sprocket.cleanup(ca, id)

      actor.Stop(process.Normal)
    }
    _ -> {
      logger.info("Received unsupported websocket message type")
      io.debug(message)

      actor.continue(state)
    }
  }
}
