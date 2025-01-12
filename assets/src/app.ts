import { DoubleClick } from "./hooks/doubleclick";
import { connect } from "sprocket-js";

const hooks = {
  DoubleClick,
};

window.addEventListener("DOMContentLoaded", () => {
  const csrfToken = document
    .querySelector("meta[name=csrf-token]")
    ?.getAttribute("content");

  if (csrfToken) {
    let connectPath =
      window.location.pathname === "/"
        ? "/connect"
        : window.location.pathname.split("/").concat("connect").join("/");

    connect(connectPath, document.querySelector("#app"), csrfToken, {
      hooks,
    });
  } else {
    console.error("Missing CSRF token");
  }
});
