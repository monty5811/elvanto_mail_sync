import Cookies from 'js-cookie';

const Elm = require('./Main.elm');

function handleDOMContentLoaded() {
  // setup elm
  Elm.Main.fullscreen({ csrftoken: Cookies.get('csrftoken') });
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
