import socket from "./socket"

import $ from "jquery"
// import 'bootstrap/js/src/index'
import 'bootstrap-sass/assets/javascripts/bootstrap'
// import 'adminator/src/assets/scripts/index'
// import 'fastclick/lib/fastclick'
// import 'nprogress/nprogress'
// import 'gentelella/src/js/custom.js'
// import 'gentelella/src/js/helpers/smartresize'

socket.connect()
let channel = socket.channel("messengers:lobby", {})
let list    = $('#message-list');
let message = $('#message');
let name    = $('#name');

console.log(channel)

message.on('keypress', event => {
  if (event.keyCode == 13) {
    channel.push('shout', {name: name.val(), message: message.val()})
    message.val('')
  }
});

channel.on('shout', payload => {
  let mssgrs = '';
  payload.messengers.forEach(messenger => {
    mssgrs += `${messenger.name} (${messenger.state}) <br>`
  });

  list.append(`<b>${payload.payload.name || 'Anonymous'}:</b> <div>${mssgrs}</div>`);
  list.prop({scrollTop: list.prop("scrollHeight")});
});

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) });