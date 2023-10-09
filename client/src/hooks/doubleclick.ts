export const doubleclick = {
  mounted({ el, pushEvent }) {
    el.addEventListener("dblclick", () => {
      pushEvent("doubleclick", {});
    });
  },
};
