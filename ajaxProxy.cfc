component {
 remote function put(required string message, required string userID){
  var message = { 'userid' = arguments.userID, 'message' = arguments.message };
  return getChat().putMessage(message);
 }

 remote function list(numeric startID = 0){
  var result = { 'svrStatus' = 0, 'svrMessage' = "OK" };
  structAppend(result, getChat().getMessages(startID = arguments.startID));
  result['clients'] = getChat().getClients()
  return result;
 }

 remote function setUser(required string userID){
  return getChat().addUser(userID = arguments.userID);
 }

 remote function clients(){
  var result = { 'svrStatus' = 0, 'svrMessage' = 'OK', 'userInfo' = getChat().getClients() };
  return result;
 }

 private function getChat(){
  return application.chat;
 }

}