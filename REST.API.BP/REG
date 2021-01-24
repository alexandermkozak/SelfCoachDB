open "USERS" to F.USERS else
   gosub error
end
open "SYSCONFIGS" to F.SYSCONFIGS else
   gosub error
end
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
details = request{"userInfo"}
logmsg "making user ":userName
logmsg "password = ":request{"password"}
logmsg "requestBodyJSON = ":requestBodyJSON
call MK.USER(userName, password, details, status, message)
if status then
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
*LOGMSG "Reg Success on ":userName
call WSETSTATUS(200)
response{'status'} = "OK"
response{'value'} = @TRUE
*response{'userInfo'} = userInfo
*
goto send.response
return
************
fail:
*LOGMSG "Reg Fail on ":userName
call WSETSTATUS(200)
response{'status'} = "OK"
response{'value'} = @FALSE
response{'message'} = message
goto send.response
return
***********
error:
*LOGMSG "Reg ERROR"
response{'status'} = "ERROR"
response{'value'} = "false"
call WSETSTATUS(500)
goto send.response
return
end
