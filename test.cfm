<cfscript>
writeDump(var = session, label = "session");
writeDump(var = application.chat.getMessages(), label = "messages");
writeDump(var = application.chat.getRooms(), label = "rooms");
</cfscript>