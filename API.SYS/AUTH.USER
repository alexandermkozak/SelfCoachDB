subroutine AUTH.USER(userName, password, result, userInfo)
open "USERS" to F.USERS else
   goto error
end
open "SYSCONFIGS" to F.SYSCONFIGS else
   goto error
end
result = @FALSE
userName = DOWNCASE(userName)
userInfo = Collection()
*
read userRec from F.USERS, userName then
   userPassword = userRec<3>
   readv pepper from F.SYSCONFIGS, "pepper", 1 else gosub error
   hashPass = DIGEST(userName:password:pepper, @FALSE, "SHA512")
   if hashPass = userPassword then
      result = @TRUE
   end
   userInfo{'Name'} = userName
   userInfo{'firstName'} = userRec<1>
   userInfo{'lastName'} = userRec<2>
   userInfo{'emailAddress'} = userRec<4>
end

return
*******
error:

return
*******
END
