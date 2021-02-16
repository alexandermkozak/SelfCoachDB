CLASS USER.B
   PRIVATE userName, firstName, lastName, password, emailAddress, roles, exists
   
   PUBLIC SUBROUTINE CREATE.OBJECT(newUserName)
      userName = DOWNCASE(newUserName)
      open 'USERS' to F.USERS else exists = @FALSE
      read userRec from F.USERS, userName then
         firstName = userRec<1>
         lastName = userRec<2>
         password = userRec<3>
         emailAddress = userRec<4>
         roles = ereplace(userRec<5>,@VM,@AM)
         exists = @TRUE
      end else
         firstName = ''
         lastName = ''
         password = ''
         emailAddress = ''
         roles = ''
         *
         exists = @FALSE
      end
   END   
   
   PUBLIC FUNCTION SAVE.OBJECT()
      open 'USERS' to F.USERS else 
         status = @FALSE
         return status
      end
      status = @TRUE
      userRec = ''
      userRec<1> = firstName
      userRec<2> = lastName
      userRec<3> = password
      userRec<4> = emailAddress
      userRec<5> = ereplace(roles,@AM,@VM)
      ** Before writing, we should check "version" to be sure we aren't writing an older version on top of a newer version
      write userRec on F.USERS, userName ON ERROR
         status = @FALSE
         logmsg \Error writing to users for \:userName:\ status: \:STATUS()
      end
      exists = (exists or status) ;* If it already existed before, don't set to false
      return status ;* Indicate we succeeded/failed to save
   END
   
   PUBLIC SUBROUTINE DELETE.OBJECT(status)
      status = @FALSE
      open 'USERS' to F.USERS then        
         if exists then
            * We'll have to do cleanup later on this. Cleanup anything associated with this user.
            delete F.USERS, userName
            exists = @FALSE        
            status = @TRUE 
         end
      end
   END
   
   PUBLIC FUNCTION TO.COLLECTION()
      userInfo = Collection()
      userInfo{"name"} = userName
      userInfo{"firstName"} = firstName
      userInfo{"lastName"} = lastName
      userInfo{"emailAddress"} = emailAddress
      userInfo{"roles"} = roles
      RETURN userInfo
   END

   PUBLIC FUNCTION TO.JSON()
      userInfo = ME->TO.COLLECTION()
      RETURN JBUILD(userInfo)
   END
   
   PUBLIC FUNCTION GET.USERNAME() 
      return userName
   END
   
   PUBLIC SUBROUTINE SET.FIRSTNAME(newFirstName) 
      firstName = newFirstName
      return
   END
   
   PUBLIC FUNCTION GET.FIRSTNAME()
      return firstName
   END
   
   PUBLIC SUBROUTINE SET.LASTNAME(newLastName) 
      lastName = newLastName
      return
   END
   
   PUBLIC FUNCTION GET.LASTNAME()
      return lastName
   END
   
   PUBLIC SUBROUTINE SET.PASSWORD(newPassword) ;* Should this contain the hashing routine?
      password = newPassword
      return
   END
   
   PUBLIC FUNCTION CHECK.PASSWORD(checkPassword) ;* I don't think we want a password going anywhere once it's here. Even if it is secure
      return (password = checkPassword)
   END
   
   PUBLIC SUBROUTINE SET.EMAIL(newEmailAddress) 
      emailAddress = newEmailAddress
      return
   END
   
   PUBLIC FUNCTION GET.EMAIL()
      return emailAddress
   END
   
   PUBLIC SUBROUTINE ADD.ROLE(newRole) 
      roles<-1> = newRole
      return
   END
   
   PUBLIC SUBROUTINE SET.ROLES(newRoles) 
      
      roles = ''
      newRolesCount = INMAT(newRoles)
      logmsg 'Setting user Roles with newRolesCount = ':newRolesCount
      for rolePtr = 1 to newRolesCount
         roles<rolePtr> = newRoles{rolePtr}
      next rolePtr

      return
   END

   PUBLIC FUNCTION GET.ROLES()
      return roles
   END
   
   PUBLIC SUBROUTINE CLEAR.ROLES()
      roles = ''
      return
   END
   
   PUBLIC FUNCTION GET.EXISTS()
      return exists
   END
   
END
