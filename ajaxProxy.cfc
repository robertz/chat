component output = false {
    remote function put(required string message, required string userID, required string room){
        var messageObj = { 'userid' = arguments.userID, 'message' = arguments.message, 'room' = arguments.room };
        return getChat().putMessage(messageObj);
    }

    remote function list(numeric startID = 0){
        var result = { 'svrStatus' = 0, 'svrMessage' = "OK" };
        structAppend(result, getChat().getMessages(startID = arguments.startID));
        result['clients'] = getChat().getClients();
        result['rooms'] = getChat().getRooms();
        return result;
    }

    remote function setUser(required string userID){
        return getChat().addUser(userID = arguments.userID);
    }

    remote function clients(){
        return { 'svrStatus' = 0, 'svrMessage' = 'OK', 'userInfo' = getChat().getClients() };
    }

    remote function rooms(){
        return { 'svrStatus' = 0, 'svrMessage' = 'OK', 'roomInfo' = getChat().getRooms() };
    }

    private function getChat(){
        return application.chat;
    }

}