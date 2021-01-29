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
   CALL WSETHEADER("Access-Control-Allow-Headers"  ,"Content-Type, Authentication, Cookies"   )
   CALL WSETHEADER("Access-Control-Allow-Methods"  ,"GET,POST,DELETE"                         )
   CALL WSEND("")
   STOP
END

CALL WGETPARAM(userId, 1)
CALL WGETPARAM(queryType, 2)
IF userId = "" then
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
logmsg REQUEST.METHOD:" USERS/":userId:" with ":requestBodyJSON:"|"
*
begin case
   case userId # "" and REQUEST.METHOD = "DELETE"
      gosub handle.delete
   case REQUEST.METHOD = "POST"
      gosub handle.post
   case REQUEST.METHOD = "GET" and userId # ""
      gosub handle.get
   case REQUEST.METHOD = "GET" and userId = ""
      gosub handle.get.list
end case
*
*******
send.response:
call WSEND(response)
RETURN
***********
handle.get.list:
*
query = \SSELECT USERS\

if not(selectAllFlag) then
   query := \ with @ID = \:userId
end

LOGMSG query
*
EXECUTE query CAPTURING MESSAGE RTNLIST USER.IDS
*
response = ""
userListPtr = 0
*
USER.CNT = DCOUNT(USER.IDS,@AM)
for USER.PTR = 1 TO USER.CNT
   user.id = USER.IDS<USER.PTR>
   user = OBJECT("USER.B", user.id)
   if user->GET.EXISTS() then
      userListPtr += 1
      response<userListPtr> = user->TO.JSON()
   end
next USER.PTR
response = "[":ereplace(response,@AM,","):"]"
*
RETURN
***********
handle.get:
user = OBJECT("USER.B", userId)
if user->GET.EXISTS() then
   response = user->TO.JSON()
   call WSETSTATUS(200)
end else
   response{'status'} = "ERROR"
   call WSETSTATUS(404)
end

RETURN
***********
handle.post:
*
request = JPARSE(requestBodyJSON)
*
user = OBJECT("USER.B", userId)
if user->GET.EXISTS() then
   if ELEMENT.EXISTS(request{"firstName"}) then
      user->SET.FIRSTNAME(request{'firstName'})
   end
   if ELEMENT.EXISTS(request{"lastName"}) then
      user->SET.LASTNAME(request{'lastName'})
   end
   if ELEMENT.EXISTS(request{"password"}) then
      readv pepper from F.SYSCONFIGS, "pepper", 1 else gosub error
      user->SET.PASSWORD(DIGEST(userName:password:pepper, @FALSE, "SHA512"))
   end
   if ELEMENT.EXISTS(request{"emailAddress"}) then
      user->SET.EMAIL(request{"emailAddress"})
   end

   status = user->SAVE.OBJECT()
   response = user->TO.JSON()
   call WSETSTATUS(200)
end else
   response{'status'} = "ERROR"
   call WSETSTATUS(404)
   response = JBUILD(response)
end
*

*
RETURN
***********
handle.delete:

user = OBJECT("USER.B", userId)
if user->GET.EXISTS() then
   user->DELETE.OBJECT(status)
   response{'status'} = "OK"
   call WSETSTATUS(200)
end else
   response{'status'} = "ERROR"
   call WSETSTATUS(404)
end
response = JBUILD(response)

RETURN
***********

error:
LOGMSG "AUTH ERROR"
response{'status'} = "ERROR"
response{'value'} = "false"
call WSETSTATUS(500)
goto send.response
return
end
