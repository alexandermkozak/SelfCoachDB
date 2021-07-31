$include keys.h

open "EVENTS" to F.EVENTS else
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
   CALL WSETHEADER("Access-Control-Allow-Headers"  ,"Content-Type, Authentication, Cookies, Access-Control-Allow-Origin, AuthToken")
   CALL WSETHEADER("Access-Control-Allow-Methods"  ,"GET,POST,DELETE"                         )
   CALL WSEND("")
   STOP
END
*
CALL WGETPARAM(userId, 1)
CALL WGETPARAM(eventId, 2)
*
call WGETBODY(requestBodyJSON)
* I have no idea why I need to do this. Somewhere junk is being added to requests and this isn't dealing
requestBodyJSON = requestBodyJSON[1,index(requestBodyJSON,"}",count(requestBodyJSON,"}"))]
requestBodyJSON = requestBodyJSON[index(requestBodyJSON,"{",1),len(requestBodyJSON)]
*
logmsg REQUEST.METHOD:" EVENTS/":userId:"/":eventId:" with ":requestBodyJSON:"|"
*
begin case
   case userId # "" and REQUEST.METHOD = "DELETE"
    *  gosub handle.delete
   case REQUEST.METHOD = "POST"
      gosub handle.post
   case REQUEST.METHOD = "GET" and userId # "" and eventId # ""
      gosub handle.get
   case REQUEST.METHOD = "GET" and userId # "" and eventId = ""
     gosub handle.get.list
end case
*
*******
send.response:
call WSEND(response)
RETURN
***********
handle.post:
*
request = JPARSE(requestBodyJSON)
*
creating = @false
if eventId = "" then
    eventId = SYSTEM(SYS$UUID)
    creating = @true
end
startDate = request{"startDate"}
endDate = request{"endDate"}
startTime = request{"startTime"}
endTime = request{"endTime"}
description = request{"description"}
title = request{"title"}

eventRec = ''
eventRec<1> = title
eventRec<2> = description
eventRec<3> = iconv(startDate,"d")
eventRec<4> = iconv(endDate,"d")
eventRec<5> = iconv(startTime,"mth")
eventRec<6> = iconv(endTime, "mth")
eventRec<7> = userId

write eventRec on F.EVENTS, eventId ON ERROR
    logmsg "Failed to write ":eventId:"!"
end
*
responseObj = Collection()
responseObj{"status"} = "ok!"
responseObj{"id"} = eventId
response = JBUILD(responseObj)
*
RETURN
***********
handle.get:

read eventRec from F.EVENTS, eventId then
    response = COLLECTION()
    response{"title"} = eventRec<1>
    response{"description"} = eventRec<2>
    response{"startDate"} = oconv(eventRec<3>,"d4/")
    response{"endDate"} = oconv(eventRec<4>, "d4/")
    response{"startTime"} = oconv(eventRec<5>, "mth")
    response{"endTime"} = oconv(eventRec<6>, "mth")
    
    response = JBUILD(response)
    call WSETSTATUS(200)
end else
   response{'status'} = "ERROR"
   call WSETSTATUS(404)
end

RETURN
***********
handle.get.list:

CALL WGETVAR(queryDate,"date")

query = \select EVENTS with userID = "\:userId:\"\
query2 = \select EVENTS with startDate <= "\:queryDate:\" and with endDate >= "\:queryDate:\"\

execute query capturing resultDesc ;* index this query
logmsg query:"|":resultDesc
if @SELECTED > 0 then
    execute query2 capturing resultDesc
    logmsg query2:"|":resultDesc
end else
    * no results
    return
end

if @SELECTED > 0 then
    DIM results(@SELECTED)
    endOfList = @FALSE
    resultPointer = 0
    loop
        readnext eventId else endOfList = @TRUE
    until endOfList do
        read eventRec from F.EVENTS, eventId then
            resultPointer += 1
            result = COLLECTION()
            result{"title"} = eventRec<1>
            result{"description"} = eventRec<2>
            result{"startDate"} = oconv(eventRec<3>,"d4/")
            result{"endDate"} = oconv(eventRec<4>, "d4/")
            result{"startTime"} = oconv(eventRec<5>, "mth")
            result{"endTime"} = oconv(eventRec<6>, "mth")
            result{"id"} = eventId
            results(resultPointer) = result
        end
    repeat

    response = JBUILD(MAT(results))
    call WSETSTATUS(200)
end else
    response = \{"status" : "None"}\
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
