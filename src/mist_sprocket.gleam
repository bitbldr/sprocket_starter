import gleam/io
import gleam/option.{type Option, Some}
import gleam/list
import gleam/result
import gleam/bytes_builder.{type BytesBuilder}
import gleam/otp/actor
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import mist.{type Connection, type ResponseData}
import sprocket.{
  type CSRFValidator, type Sprocket, type SprocketOpts, Empty, Joined,
  render_html,
}
import sprocket/component as sprocket_component
import sprocket/context.{type Element, type FunctionalComponent}
import sprocket/internal/logger

type State {
  State(spkt: Sprocket)
}

pub fn component(
  req: Request(Connection),
  view: FunctionalComponent(p),
  props: p,
  csrf_validator: CSRFValidator,
  opts: Option(SprocketOpts),
) -> Response(ResponseData) {
  let selector = process.new_selector()
  let rendered_el = sprocket_component.component(view, props)

  // if the request path ends with "live", then start a websocket connection
  case list.last(request.path_segments(req)) {
    Ok("live") -> {
      mist.websocket(
        request: req,
        on_init: fn(conn) {
          #(
            State(sprocket.new(rendered_el, sender(conn), csrf_validator, opts)),
            Some(selector),
          )
        },
        on_close: fn(state) {
          let _ = sprocket.cleanup(state.spkt)

          Nil
        },
        handler: handle_ws_message,
      )
    }

    _ -> {
      let body = render_html(rendered_el)

      response.new(200)
      |> response.set_body(body)
      |> response.prepend_header("content-type", "text/html")
      |> response.map(bytes_builder.from_string)
      |> mist_response()
    }
  }
}

pub fn view(
  req: Request(Connection),
  layout: fn(Element) -> Element,
  view: FunctionalComponent(p),
  props: p,
  csrf_validator: CSRFValidator,
  opts: Option(SprocketOpts),
) -> Response(ResponseData) {
  let selector = process.new_selector()
  let rendered_el = sprocket_component.component(view, props)

  // if the request path ends with "live", then start a websocket connection
  case list.last(request.path_segments(req)) {
    Ok("live") -> {
      mist.websocket(
        request: req,
        on_init: fn(conn) {
          #(
            State(sprocket.new(rendered_el, sender(conn), csrf_validator, opts)),
            Some(selector),
          )
        },
        on_close: fn(state) {
          let _ = sprocket.cleanup(state.spkt)

          Nil
        },
        handler: handle_ws_message,
      )
    }
    _ -> {
      let body = render_html(layout(rendered_el))

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

fn handle_ws_message(state, _conn, message) {
  let State(spkt) = state

  case message {
    mist.Text(msg) -> {
      case sprocket.handle_ws(spkt, msg) {
        Ok(response) -> {
          case response {
            Joined(spkt) -> {
              actor.continue(State(spkt))
            }
            Empty -> {
              actor.continue(state)
            }
          }
        }
        Error(err) -> {
          logger.error("failed to handle websocket message: " <> msg)
          io.debug(err)

          actor.continue(state)
        }
      }
    }
    mist.Closed | mist.Shutdown -> {
      actor.Stop(process.Normal)
    }
    _ -> {
      logger.info("Received unsupported websocket message type")
      io.debug(message)

      actor.continue(state)
    }
  }
}

fn sender(conn) {
  fn(msg) {
    mist.send_text_frame(conn, msg)
    |> result.map_error(fn(reason) {
      logger.error("failed to send websocket message: " <> msg)
      io.debug(reason)

      Nil
    })
  }
}
