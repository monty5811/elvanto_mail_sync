import Cookies from 'js-cookie';

const Elm = require('./Main.elm');
const version = 'v1'; // change this if our model changes!

function loadFromStorage(key) {
  console.log(`Fetching ${key} from cache`);
  const cache = localStorage.getItem(`${version}-${key}`);
  if (cache === null) {
    return [];
  }
    return JSON.parse(cache);
}

function handleDOMContentLoaded() {
  // setup elm
  const app = Elm.Main.fullscreen({
    csrftoken: Cookies.get('csrftoken'),
    groupsCache: loadFromStorage('groups'),
    peopleCache: loadFromStorage('people'),
  });

  app.ports.saveGroups.subscribe(function(groups) {
    console.log('Caching groups');
    localStorage.setItem(`${version}-groups`, JSON.stringify(groups))
  });
  app.ports.savePeople.subscribe(function(people) {
    console.log('Caching people');
    localStorage.setItem(`${version}-people`, JSON.stringify(people))
  });
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false);
