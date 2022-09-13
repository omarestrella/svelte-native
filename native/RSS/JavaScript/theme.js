let lightTheme = "cmyk"
let darkTheme = "business"

function setLightTheme() {
  document.querySelector("html").dataset.theme = lightTheme;
  document.body.style.backgroundColor = "rgb(255, 255, 255)"
}

function setDarkTheme() {
  document.querySelector("html").dataset.theme = darkTheme;
  document.body.style.backgroundColor = "rgb(33, 33, 33)"
}

window.setLightTheme = setLightTheme;
window.setDarkTheme = setDarkTheme;
