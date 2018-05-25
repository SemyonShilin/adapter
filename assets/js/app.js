// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
// import "phoenix_html";
// import socket from "./socket";
// import filePicker from './components/filePicker'
// import 'bootstrap/dist/css/bootstrap.min.css';


// import React from 'react';
// import ReactDOM from 'react-dom';
// import { Button } from 'reactstrap';
// //
// export default (props) => {
//   return (
//     <Button color="danger">Danger!</Button>
//   );
// };
import React from 'react';
import ReactDOM from 'react-dom';
import socket from "./socket";
import { Button } from 'reactstrap';

ReactDOM.render(
  <Button color="danger">Danger!</Button>,
  document.getElementById('root')
);
