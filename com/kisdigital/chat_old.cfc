<cfcomponent>
 <cfscript>
  variables.instance = structNew();
  instance.chatHistory = arrayNew(1);
  instance.clients = arrayNew(1);
  instance.messageTotal = arrayLen(instance.chatHistory);
 </cfscript>

 <cffunction name="init" access="public" returntype="chat">
  <cfreturn this/>
 </cffunction>

 <cffunction name="postMessage" access="public" returntype="struct">
  <cfargument name="message" type="string" required="yes"/>
  <cfargument name="userName" type="string" required="yes"/>

  <cflock name="lockForWritingMessages" type="exclusive" timeout="5">
  <cfscript>
   var result = structNew();
   var tempData = structNew();

   result['svrStatus'] = "0";
   result['svrMessage'] = "OK";
   tempData['userid'] = arguments.userName;
   tempData['message'] = arguments.message;
   tempData['msgid'] = instance.messageTotal + 1;
   instance.messageTotal++;
   arrayAppend(instance.chatHistory, tempData);
   if(arrayLen(instance.chatHistory) gt 100) arrayDeleteAt(instance.chatHistory, 1);
  </cfscript>
  </cflock>
  <cfreturn result/>
 </cffunction>

 <cffunction name="getMessages" access="public" returntype="struct">
  <cfargument name="startID" type="numeric" required="no" default="0"/>
  <cfscript>
   var result = structNew();
   var i = 0;
   var startIdx = 0;
   var msgCnt = arrayLen(instance.chatHistory);

   result['svrStatus'] = "0";
   result['svrMessage'] = "OK";
   result['lastid'] = instance.messageTotal;
   if(arguments.startID eq 0){
    result['messages'] = instance.chatHistory;
   }
   else{
    result['messages'] = arrayNew(1);
    for(i = 1; i lte msgCnt; i++){
	 if(instance.chatHistory[i].msgid gt arguments.startID)
	  arrayAppend(result['messages'], instance.chatHistory[i]);
	}
   }
   return result;
  </cfscript>
 </cffunction>

</cfcomponent>