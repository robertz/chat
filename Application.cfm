<cfapplication
 name="chatapp"
 clientmanagement="true"
 sessionmanagement="true"
 secureJSON="false"
 />
<cfif not structKeyExists(application, "chat") or structKeyExists(url, "reinit")>
 <cfset application.chat = new com.kisdigital.chat() />
 <cfset structClear(session) />
</cfif>
<cfif not structKeyExists(session, "userid")>
 <cfset session.userid = "" />
</cfif>