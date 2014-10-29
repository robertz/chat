component name="chat" accessors="false" {

    public chat function init(){
        variables.history = [];
        variables.clients = [];
        // What clients are in which rooms
        variables.clientsByRoom = {};

        variables.rooms = [];
        variables.messageCount = 0; // The ID of the last message
        variables.birth = Now();
        return this;
    }

    public void function reset(){
        variables.history = [];
        variables.clients = [];
        variables.messageCount = 0;
    }

    public struct function getMessages(numeric startID = 0){
        lock name='lockForReadingMessage' type='exclusive' timeout='5' {
            var messageCount = arrayLen(variables.history);
            var result = {'lastid' = variables.messageCount, 'messages' = [] };
            if(!arguments.startID){
                result['messages'] = variables.history;
                return result;
            }
            for(var i = 1; i <= messageCount; i++){
                if(variables.history[i].msgid > arguments.startID) arrayAppend(result['messages'], variables.history[i]);
            }
        }
        clientManager(userid = session.userid);
        return result;
    }

    public boolean function putMessage(required struct message, string type = 'message', boolean manage = true){
        lock name='lockForWritingMessage' type='exclusive' timeout='5' {
            variables.messageCount++;
            var cleanedMessage = {
                 'timestamp' = dateFormat(Now(), 'm/d/yyyy') & ' ' & timeFormat(Now(), 'h:mm tt')
                ,'userid' = arguments.message.userid
                ,'type' = arguments.type
                ,'message' = stripHTML(arguments.message.message)
                ,'msgid' = variables.messageCount
                ,'roomid' = arguments.message.room
            };
            arrayAppend(variables.history, cleanedMessage);
            if(arrayLen(variables.history) > 100) arrayDeleteAt(variables.history, 1);
        }
        // if the room does not exist, add it
        if(!arrayFind(variables.rooms, arguments.message.room)){
            arrayAppend(variables.rooms, arguments.message.room);
        }
        // Now update the client stuff
        if(arguments.manage) clientManager(arguments.message.userid);
        return true;
    }

    // checks to see if a userid is available, adds it if it is
    public struct function addUser(required string userid){
        lock name='lockForClientManagement' type='exclusive' timeout='5' {
            var clientCount = arrayLen(variables.clients);
            var clientFound = false;
            var result = {};
            for(var i = 1; i <= clientCount; i++){
                if(variables.clients[i].userid == arguments.userid){
                    clientFound = true;
                    continue;
                }
            }

            if(!clientFound && lcase(arguments.userid) != 'system'){
                // Oooooooh, something new
                var created = Now();
                arrayAppend(variables.clients, { 'userid' = arguments.userid, 'created' = created, 'lastupdated' = created });
                clientCount++;
                result = {'svrStatus' = '0', 'svrMessage' = 'OK'};
                session.userid = arguments.userid;
                putMessage(message = { 'userid' = 'SYSTEM', 'message' = '*** User ' & arguments.userid & ' has joined the chat', 'room' = 'lobby'}, type = 'notice', manage = false);
            }
            else{
                result = {'svrStatus' = '-1', 'svrMessage' = 'That userid is already being used or is reserved!'};
            }
        }
        return result;
    }

    // Adds a room for chat
    public void function addRoom(required string room){
        arrayAppend(variables.rooms, arguments.room);
    }

    // get a list of connected clients
    public array function getClients(){
        return variables.clients;
    }

    // get a list of rooms
    public array function getRooms(){
        return variables.rooms;
    }

    // when was the component created
    public string function getBirth(){
        return dateFormat(variables.birth, "m/d/yyyy") & ' ' & timeFormat(variables.birth, "h:mm:ss tt");
    }

     /***
     * Private functions
     */

    private string function stripHTML(required string input){
        return REReplaceNoCase (arguments.input, "(<[^>]+>)" , "", "ALL");
    }

    // Track who is on
    private void function clientManager(required string userid){
        lock name='lockForClientManagement' type='exclusive' timeout='5' {
            var clientCount = arrayLen(variables.clients);
            var clientFound = false;
            for(var i = 1; i <= clientCount; i++){
                if(variables.clients[i].userid == arguments.userid){
                clientFound = true;
                variables.clients[i]['lastupdated'] = Now();
                continue;
                }
            }
            if(!clientFound){
                // Oooooooh, something new
                var created = Now();
                arrayAppend(variables.clients, { 'userid' = arguments.userid, 'created' = created, 'lastupdated' = created });
                clientCount++;
            }
            // Time for some pruning
            for(i = clientCount; i > 0; i--){
                if(abs(dateDiff("n", now(), variables.clients[i].lastUpdated)) gt 1){
                    putMessage(message = { 'userid' = 'SYSTEM', 'message' = '*** User ' & variables.clients[i].userid & ' removed from the system for inactivity', 'room' = 'lobby'}, 'type' = 'notice', manage = false);
                    arrayDeleteAt(variables.clients, i);
                }
            }
        }
    }

}