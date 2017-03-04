window.haveOpenedReg = false;
(function(){
  var show = function(el){
    return function(msg){ el.innerHTML = msg + '<br />' + el.innerHTML; }
  }(document.getElementById('msgs'));

  var ws       = new WebSocket('ws://' + window.location.host + '/socket');
  ws.onopen    = function()  { show('websocket opened'); };
  ws.onclose   = function()  { show('websocket closed'); }
  ws.onmessage = function(m) {
    show('websocket message: ' +  m.data);
    if(m.data.indexOf(':') >= 0) //activation url
      if(!window.haveOpenedReg){
	window.open(m.data, "_blank");
	window.haveOpenedReg = true;
      }else show('already opened registration tho');
    else{ //assigned email id
      var el = document.getElementById("email");
      el.value = m.data + "@24nm.us";
      document.getElementById("copyemail_button").disabled = false;
    }
  };
})();

function copyemail(){
  var el = document.getElementById("email");
  el.select();
  try {
    var successful = document.execCommand('copy');
    var msg = successful ? 'successful' : 'unsuccessful';
    console.log('Copying text command was ' + msg);
    window.open("https://secured.clubpenguin.com/penguin/create", "_blank");
  } catch (err) {
    console.log('Oops, unable to copy');
  }
}

//Immediately upon loading, attempt open a page which immediately closes. Because this is not a user-initiated action, this will trigger the popup blocker which then allows the speedrunner to click the button to allow popups for this website.
window.open("/close.html","_blank");
