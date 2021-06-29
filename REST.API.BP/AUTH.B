open "USERS" to F.USERS else
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

userName = ""
password = ""
response = COLLECTION()
*
call WGETBODY(requestBodyJSON)
* I have no idea why I need to do this. Somewhere junk is being added to requests and this isn't dealing
requestBodyJSON = requestBodyJSON[1,index(requestBodyJSON,"}",count(requestBodyJSON,"}"))]
requestBodyJSON = requestBodyJSON[index(requestBodyJSON,"{",1),len(requestBodyJSON)]
*
request = JPARSE(requestBodyJSON)

userName = request{"userName"}
password = request{"password"}

call AUTH.USER.B(userName, password, result, userInfo, session, statusMessage)
if result then
  gosub success
end else
   gosub fail
end

send.response:
responseJSON = JBUILD(response)
call WSEND(responseJSON)
stop
************
success:
*LOGMSG "Auth Success on ":userName
call WSETSTATUS(200)
response{'status'} = "OK"
response{'value'} = @TRUE
response{'userInfo'} = userInfo->TO.COLLECTION();
response{'sessionInfo'} = session->TO.COLLECTION();
*
goto send.response
return
************
fail:
*LOGMSG "Auth Fail on ":userName
call WSETSTATUS(200)
response{'status'} = "OK"
response{'value'} = @FALSE
response{'statusMessage'} = statusMessage
goto send.response
return
***********
error:
*LOGMSG "AUTH ERROR"
response{'status'} = "ERROR"
response{'value'} = "false"
call WSETSTATUS(500)
goto send.response
return
end
