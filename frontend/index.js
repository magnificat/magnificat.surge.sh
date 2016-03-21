require('style!jss-lite!./styles');

const FontFaceObserver = require('fontfaceobserver');

// Prevent FOIT
const waitForMerriweather = new FontFaceObserver('Merriweather Light');
waitForMerriweather.check().then(() => {
  document.documentElement.setAttribute('data-fonts-loaded', '');
});

// Wire things up
const Elm = require('./Main.elm');
const main = document.getElementById('main');
Elm.embed(Elm.Main, main);
