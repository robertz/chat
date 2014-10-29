<cfoutput>
<!DOCTYPE html>
<html>
 <head>
  <meta charset=utf-8 />
  <title>Simple Chat</title>
  <script type="text/javascript">
   window.chat = {};
   window.chat.userid = '#session.userid#';
  </script>
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
  <style>
   body{
    margin-top: 32px;
   }
   .user{
    padding: 2px;
   }
  </style>
 </head>

 <body>
  <div class="container">
   <div id="messageContainer" style="display: none;">
    <div class="row">
     <div class="col-md-10">
      <div id="chatDiv" style="height: 300px; border: 1px solid gray; overflow: auto;"></div>
      <br />
      <input class="form-control" id="message" type="text" />
      <select id="roomsel">
      </select>
     </div>
     <div class="col-md-2">
      <div id="userList" style="height: 300px; border: 1px solid gray; overflow: auto;"></div>
     </div>
    </div>

   </div>

   <div id="nameContainer" style="display: none;">
    <input id="userName" type="text" />
    <input type="button" id="setName" value="Set Name" />
   </div>
  </div>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
  <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
  <script src="chat.js"></script>
 </body>
</html>
</cfoutput>