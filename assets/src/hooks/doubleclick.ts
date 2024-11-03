import { ClientHook } from "sprocket-js";

export const DoubleClick: ClientHook = {
  create({ el, pushEvent }) {
    el.addEventListener("dblclick", () => {
      pushEvent("doubleclick", {});
    });
  },
};
