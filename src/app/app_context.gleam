import sprocket.{type CSRFValidator}

pub type AppContext {
  AppContext(secret_key_base: String, validate_csrf: CSRFValidator)
}
