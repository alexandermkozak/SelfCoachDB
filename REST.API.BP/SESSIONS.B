open "SESSIONS" to F.SESSIONS else
   gosub error
end
open "SYSCONFIGS" to F.SYSCONFIGS else
   gosub error
end

CALL WSETCONTENTTYPE("application/json")
*
CALL WSETHEADER("Access-Control-Allow-Origin","*")
*
* Get our request_method
*
CALL WGETHEADER(REQUEST.METHOD,"REQUEST_METHOD")
*
* Special code for CORS.  If cors kicks and a OPTION request is sent by the browser the
* following code will make this work.  This is a development only item.  For production
* you want to read the CORS documents.
*
IF REQUEST.METHOD = "OPTIONS" THEN
   CALL WSETHEADER("Access-Control-Headers"        ,"Content-Type, Authentication"            )
   CALL WSETHEADER("Access-Control-Allow-Headers"  ,"Content-Type, Authentication, Cookies, Access-Control-Allow-Origin"   )
   CALL WSETHEADER("Access-Control-Allow-Methods"  ,"GET,POST,DELETE"                         )
   CALL WSEND("")
   STOP
END

CALL WGETPARAM(sessionId, 1)
CALL WGETPARAM(queryType, 2)
IF sessionId = "" then
   selectAllFlag = @TRUE
end else
   selectAllFlag = @FALSE
end
*
call WGETBODY(requestBodyJSON)
* I have no idea why I need to do this. Somewhere junk is being added to requests and this isn't dealing
requestBodyJSON = requestBodyJSON[1,index(requestBodyJSON,"}",count(requestBodyJSON,"}"))]
requestBodyJSON = requestBodyJSON[index(requestBodyJSON,"{",1),len(requestBodyJSON)]
*
logmsg REQUEST.METHOD:" SESSIONS/":sessionId:" with ":requestBodyJSON:"|"
*
begin case
   case sessionId # "" and REQUEST.METHOD = "DELETE"
    *  gosub handle.delete
   case REQUEST.METHOD = "POST"
      gosub handle.post
   case REQUEST.METHOD = "GET" and sessionId # ""
      gosub handle.get
   case REQUEST.METHOD = "GET" and sessionId = ""
     * gosub handle.get.list
end case
*
*******
send.response:
call WSEND(response)
RETURN
***********
handle.post:
*
session = OBJECT("SESSION.B", sessionId)
*
if queryType = "Logout" then
   if session->GET.EXISTS() then
      ignore = session->LOGOUT.SESSION()
      ignore = session->SAVE.OBJECT()
      response = session->TO.JSON()
      call WSETSTATUS(200)
   end else
      LOGMSG "Session doesn't exist!"
      gosub error
   end
end else
   LOGMSG "No valid endpoint!"
   gosub error
end
*
RETURN
***********
handle.get:
session = OBJECT("SESSION.B", sessionId)
if session->GET.EXISTS() then
   response = session->TO.JSON()
   call WSETSTATUS(200)
end else
   response{'status'} = "ERROR"
   call WSETSTATUS(404)
end

RETURN

***********

error:
LOGMSG "SESSION ERROR"
responseObject = collection()
responseObject{'status'} = "ERROR"
responseObject{'value'} = "false"
response = JBUILD(responseObject)
call WSETSTATUS(500)
goto send.response
return
end
