$include keys.h
CLASS ROLE.B
    PRIVATE id, name, exists
    PUBLIC SUBROUTINE CREATE.OBJECT(newId)
        open 'ROLES' to F.ROLES else exists = @FALSE
        read roleRec from F.ROLES, newId then
            id = newId
            name = roleRec<1>
            exists = @TRUE
        end else
            id = SYSTEM(SYS$UUID)
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
      name = DOWNCASE(newName)
      logmsg "Set role name to ":name
      return
    END
   
    PUBLIC FUNCTION GET.NAME()
      return name
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
      END
      RETURN JBUILD(roleInfo)
    END
END