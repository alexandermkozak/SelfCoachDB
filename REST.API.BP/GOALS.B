open "GOALS" to F.GOALS else
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

CALL WGETPARAM(goalId, 1)
CALL WGETPARAM(queryType, 2)
*
call WGETBODY(requestBodyJSON)
* I have no idea why I need to do this. Somewhere junk is being added to requests and this isn't dealing
requestBodyJSON = requestBodyJSON[1,index(requestBodyJSON,"}",count(requestBodyJSON,"}"))]
requestBodyJSON = requestBodyJSON[index(requestBodyJSON,"{",1),len(requestBodyJSON)]
*
logmsg REQUEST.METHOD:" GOALS/":goalId:" with ":requestBodyJSON:"|"
*
begin case
   case goalId # "" and REQUEST.METHOD = "DELETE"
      gosub handle.delete
   case REQUEST.METHOD = "POST"
      gosub handle.post
   case REQUEST.METHOD = "GET" and goalId # ""
      gosub handle.get
   case REQUEST.METHOD = "GET" and goalId = ""
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
query = \SSELECT GOALS\
** Validate Owner

LOGMSG query
*
EXECUTE query CAPTURING MESSAGE RTNLIST GOAL.IDS
*
response = ""
goalListPtr = 0
*
GOAL.CNT = DCOUNT(GOAL.IDS,@AM)
for GOAL.PTR = 1 TO GOAL.CNT
   goal.id = GOAL.IDS<GOAL.PTR>
   goal = OBJECT("GOAL.B", goal.id)
   if goal->GET.EXISTS() then
      goalListPtr += 1
      response<goalListPtr> = goal->TO.JSON()
   end
next GOAL.PTR
response = "[":ereplace(response,@AM,","):"]"
*
RETURN
***********
handle.get:
goal = OBJECT("GOAL.B", goalId)
if goal->GET.EXISTS() then
   response = goal->TO.JSON()
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
goal = OBJECT("GOAL.B", goalId)
if goal->GET.EXISTS() then
   if ELEMENT.EXISTS(request{"name"}) then
      goal->SET.NAME(request{'name'})
   end
   if ELEMENT.EXISTS(request{"description"}) then
      goal->SET.DESCRIPTION(request{'description'})
   end
   if ELEMENT.EXISTS(request{"owner"}) then
      goal->SET.OWNER(request{'owner'})
   end
   goalStatus = goal->SAVE.OBJECT()
end else
   CALL CREATE.GOAL.B(request, goal, goalStatus)
end

response = goal->TO.JSON()
call WSETSTATUS(200)
*

*
RETURN
***********
handle.delete:

goal = OBJECT("GOAL.B", goalId)
if goal->GET.EXISTS() then
   goal->DELETE.OBJECT(status)
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
