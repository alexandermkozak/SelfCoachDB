open "ROLES" to F.ROLES else
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

CALL WGETPARAM(roleId, 1)
CALL WGETPARAM(queryType, 2)
IF roleId = "" then
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
logmsg REQUEST.METHOD:" ROLES/":roleId:" with ":requestBodyJSON:"|"
*
begin case
   case roleId # "" and REQUEST.METHOD = "DELETE"
      gosub handle.delete
   case REQUEST.METHOD = "POST"
      gosub handle.post
   case REQUEST.METHOD = "GET" and roleId # ""
      gosub handle.get
   case REQUEST.METHOD = "GET" and roleId = ""
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
query = \SSELECT ROLES\

if not(selectAllFlag) then
   query := \ with @ID = \:roleId
end

LOGMSG query
*
EXECUTE query CAPTURING MESSAGE RTNLIST ROLE.IDS
*
response = ""
roleListPtr = 0
*
ROLE.CNT = DCOUNT(ROLE.IDS,@AM)
for ROLE.PTR = 1 TO ROLE.CNT
   role.id = ROLE.IDS<ROLE.PTR>
   role = OBJECT("ROLE.B", role.id)
   if role->GET.EXISTS() then
      roleListPtr += 1
      response<roleListPtr> = role->TO.JSON()
   end
next ROLE.PTR
response = "[":ereplace(response,@AM,","):"]"
*
RETURN
***********
handle.get:
role = OBJECT("ROLE.B", roleId)
if role->GET.EXISTS() then
   response = role->TO.JSON()
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
role = OBJECT("ROLE.B", roleId)
*if role->GET.EXISTS() then
if ELEMENT.EXISTS(request{"name"}) then
   role->SET.NAME(request{'name'})
end
if ELEMENT.EXISTS(request{"systemAdmin"}) then
   role->SET.SYSTEM.ADMIN(request{'systemAdmin'})
end
if ELEMENT.EXISTS(request{"userAdmin"}) then
   role->SET.USER.ADMIN(request{'userAdmin'})
end
status = role->SAVE.OBJECT()
response = role->TO.JSON()
call WSETSTATUS(200)
*end else
*   if ELEMENT.EXISTS(request{"name"}) then
*      role->SET.NAME(request{'name'})
*   end
*   if ELEMENT.EXISTS(request{"systemAdmin"}) then
*      role->SET.SYSTEM.ADMIN(request{'systemAdmin'})
*   end
*   if ELEMENT.EXISTS(request{"userAdmin"}) then
*      role->SET.USER.ADMIN(request{'userAdmin'})
*   end
*   status = role->SAVE.OBJECT()
*   response = role->TO.JSON()
*   call WSETSTATUS(200)
*end
*

*
RETURN
***********
handle.delete:

role = OBJECT("ROLE.B", roleId)
if role->GET.EXISTS() then
   role->DELETE.OBJECT(status)
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
