$include keys.h
CLASS ROLE.B
    PRIVATE id, name, systemAdmin, userAdmin, exists
    PUBLIC SUBROUTINE CREATE.OBJECT(newId)
        open 'ROLES' to F.ROLES else exists = @FALSE
        read roleRec from F.ROLES, newId then
            id = newId
            name = roleRec<1>
            systemAdmin = roleRec<2>
            userAdmin = roleRec<3>
            exists = @TRUE
        end else
            id = SYSTEM(SYS$UUID)
            systemAdmin = @FALSE
            userAdmin = @FALSE
            exists = @FALSE
        end
    END

    PUBLIC FUNCTION SAVE.OBJECT()
      open 'ROLES' to F.ROLES else 
         status = @FALSE
         return status
      end
      status = @TRUE
      roleRec = ''
      roleRec<1> = name
      roleRec<2> = systemAdmin
      roleRec<3> = userAdmin
      ** Before writing, we should check "version" to be sure we aren't writing an older version on top of a newer version
      write roleRec on F.ROLES, id ON ERROR
         status = @FALSE
         logmsg \Error writing to ROLES for \:id:\ status: \:STATUS()
      end
      exists = (exists or status) ;* If it already existed before, don't set to false
      return status ;* Indicate we succeeded/failed to save
    END
    
    PUBLIC SUBROUTINE DELETE.OBJECT(status)
      status = @FALSE
      open 'ROLES' to F.ROLES then        
         if exists then
            * We'll have to do cleanup later on this. Cleanup anything associated with this user.
            delete F.ROLES, id
            exists = @FALSE        
            status = @TRUE 
         end
      end
    END

    PUBLIC SUBROUTINE SET.NAME(newName) 
      name = newName
      return
    END
   
    PUBLIC FUNCTION GET.NAME()
      return name
    END

    PUBLIC SUBROUTINE SET.SYSTEM.ADMIN(newVal) 
      systemAdmin = newVal
      return
    END
   
    PUBLIC FUNCTION GET.SYSTEM.ADMIN()
      return systemAdmin
    END

    PUBLIC SUBROUTINE SET.USER.ADMIN(newVal) 
      userAdmin = newVal
      return
    END
   
    PUBLIC FUNCTION GET.USER.ADMIN()
      return userAdmin
    END

    PUBLIC FUNCTION GET.EXISTS()
      return exists
    END

    PUBLIC FUNCTION GET.ID()
      return id
    END

    PUBLIC FUNCTION TO.JSON()
      roleInfo = Collection()
      if exists then
        roleInfo{"id"} = id
        roleInfo{"name"} = name
        if not(systemAdmin) then systemAdmin = @FALSE else systemAdmin = @TRUE
        if not(userAdmin) then userAdmin = @FALSE else userAdmin = @TRUE
        roleInfo{"systemAdmin"} = systemAdmin
        roleInfo{"userAdmin"} = userAdmin
      END
      RETURN JBUILD(roleInfo)
    END
END