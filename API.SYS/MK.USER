subroutine MK.USER(userName, password, details = '', status, msg) VAR.ARGS
open "USERS" to F.USERS else
   goto error
end
open "SYSCONFIGS" to F.SYSCONFIGS else
   goto error
end
status = @FALSE
*** Old Version
*userName = DOWNCASE(userName)
*read user.rec from F.USERS, userName then
*msg = "User Exists!"
*end else
*readv pepper from F.SYSCONFIGS, "pepper", 1 else gosub error
*if ELEMENT.EXISTS(details{"firstName"}) then
*user.rec<1> = details{'firstName'}
*end
*if ELEMENT.EXISTS(details{"lastName"}) then
*user.rec<2> = details{'lastName'}
*end
*user.rec<3> = DIGEST(userName:password:pepper, @FALSE, "SHA512")
*if ELEMENT.EXISTS(details{"emailAddress"}) then
*user.rec<4> = details{"emailAddress"}
*end
*write user.rec on F.USERS, userName ON ERROR goto error
*status = @TRUE
*end
***
*** Proposed new version
user = OBJECT("USER", userName)
userName = user->GET.USERNAME()
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
