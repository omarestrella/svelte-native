let lightTheme = "cmyk";
let darkTheme = "business";

export function setLightTheme() {
  document.querySelector("html").dataset.theme = lightTheme;
}

export function setDarkTheme() {
  document.querySelector("html").dataset.theme = darkTheme;
}
