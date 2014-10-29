 var userName = window.chat.userid;
 var currID = 0;
 var nl = '<br />';
 var refreshTimer;
 knownRooms = [];

$(document).ready(function(){
	$get = $('#getMsgs');
	$win = $('#chatDiv');
	$msg = $('#message');
	$send = $('#send');
	$rm = $('#roomsel');

	if(userName == ''){
		$('#nameContainer').show();
	}
	else{
		$('#messageContainer').show();
		getMessages();
	}

	$msg.focus();
	$(document)
		.on('click', '#setName', function(){
			if( $('#userName').val().length){
				userName = $('#userName').val();
				$.ajax({
					url: 'ajaxProxy.cfc'
					,async: false
					,data: {
					userid: userName
					,method: 'setUser'
					}
					,cache: false
				});
				$('#nameContainer').hide();
				$('#messageContainer').show();
				getMessages();
			}
			else{
				alert('For real?!? Nah, you\'re kidding.  Enter a name.');
			}
		})
		.on('keyup', function(e){
			if($('#message').is(':focus') && (e.keyCode == 13)) postMessage();
		});
});


 function postMessage(){
 	console.log($rm.val());
	$.ajax({
		url  : 'ajaxProxy.cfc?returnFormat=json',
		cache: false,
		data  : {
			method : 'put',
			userid: userName,
			message : $msg.val(),
			room: $rm.val()
		},
		success : function(data){
			getMessages();
		},
		error : function(){
			$win.append('Error connecting to remote CFC');
		}
	});
	$msg.val('');
 }

function getMessages(){
	$.ajax({
		url  : 'ajaxProxy.cfc?returnFormat=json',
		cache: false,
		data  : {
			method : 'list',
			startID : currID
		},
		success : function(data){
			var res = typeof(data) !== "object" ? $.parseJSON(data) : data;
			var out = '';
			if(res.svrStatus == '0'){
				for(i=0; i < res.messages.length; i++){
					if(res.messages[i].msgid > currID){
						$('<div />')
						.html(res.messages[i].timestamp + ' [' + res.messages[i].roomid + '] ' + '<strong>' + res.messages[i].userid + '</strong>: ' + res.messages[i].message)
						.appendTo($('#chatDiv'));
					}
				}
				currID = res.lastid;
				if(res.clients.length){
					$('#userList').html('');
					for(var i=0; i < res.clients.length; i++){
						$('<div />')
						.html('<i class="glyphicon glyphicon-user" /> ' + res.clients[i].userid)
						.addClass('user')
						.appendTo($('#userList'));
					}
				}
				if(res.rooms.length){
					if(knownRooms.length != res.rooms.length){
						console.log(knownRooms.length + ' ' + res.rooms.length);
						$rm
						.children()
						.remove();
						for(var i = 0; i < res.rooms.length; i++){
							$('<option/>')
							.val(res.rooms[i])
							.html(res.rooms[i])
							.appendTo('#roomsel');
						}
						knownRooms = res.rooms;
					}
				}
				setScroll();
				
			}
		},
		error : function(){
		$win.append('Error connecting to remote CFC');
		setScroll();
		}
	});
	clearTimeout(refreshTimer);
	refreshTimer = window.setTimeout("getMessages()", 2000);
}

function setScroll(){
	$('#chatDiv').prop('scrollTop', $('#chatDiv').prop('scrollHeight'));
}
