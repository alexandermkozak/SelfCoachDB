subroutine MK.USER.B(userName, password, details = '', status, msg) VAR.ARGS
open "USERS" to F.USERS else
   goto error
end
open "SYSCONFIGS" to F.SYSCONFIGS else
   goto error
end
status = @FALSE
*
user = OBJECT("USER.B", userName)
userName = user->GET.USERNAME() ;* Reformat username to fit User object's formatting.
if user->GET.EXISTS() then
   msg = "User Exists!"
end else
   if ELEMENT.EXISTS(details{"firstName"}) then
      user->SET.FIRSTNAME(details{'firstName'})
   end
   if ELEMENT.EXISTS(details{"lastName"}) then
      user->SET.LASTNAME(details{'lastName'})
   end
   readv pepper from F.SYSCONFIGS, "pepper", 1 else gosub error
   user->SET.PASSWORD(DIGEST(userName:password:pepper, @FALSE, "SHA512"))
   if ELEMENT.EXISTS(details{"emailAddress"}) then
      user->SET.EMAIL(details{"emailAddress"})
   end
   status = user->SAVE.OBJECT()
   if not(status) then
      msg = "Failed to save user!"
   end
end
***
return
*******
error:
msg = "An error occurred while trying to save!"
return
*******
END
