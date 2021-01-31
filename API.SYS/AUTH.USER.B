subroutine AUTH.USER.B(userName, password, result, user, session, statusMessage)
open "SYSCONFIGS" to F.SYSCONFIGS else
   goto error
end
result = @FALSE
userName = DOWNCASE(userName)
userInfo = Collection()
statusMessage = ""
*
user = OBJECT("USER.B", userName)
if not(user->GET.EXISTS()) then
   statusMessage = "InvalidUser";
   goto error
end

readv pepper from F.SYSCONFIGS, "pepper", 1 else gosub error
hashPass = DIGEST(userName:password:pepper, @FALSE, "SHA512")
if not(user->CHECK.PASSWORD(hashPass)) then
   statusMessage = "InvalidPassword";
   goto error
end
*
call CREATE.SESSION.B(user, session, sessionStatus, sessionStatusMessage)
IF sessionStatus = @FALSE THEN
   result = @FALSE
   statusMessage = sessionStatusMessage
   goto error
END
*
result = @TRUE
*
return
*******
error:
result = @FALSE
user = ""
return
*******
END
