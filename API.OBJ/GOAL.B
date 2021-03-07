$include keys.h
CLASS GOAL.B
    PRIVATE id, name, owner, description, exists
    PUBLIC SUBROUTINE CREATE.OBJECT(newId)
        open 'GOALS' to F.GOALS else exists = @FALSE
        read GoalRec from F.GOALS, newId then
            id = newId
            name = GoalRec<1>
            owner = GoalRec<2>
            description = GoalRec<3>
            exists = @TRUE
        end else
            id = SYSTEM(SYS$UUID)
            exists = @FALSE
            name = ''
            owner = ''
            description = ''
        end
    END

    PUBLIC FUNCTION SAVE.OBJECT()
      open 'GOALS' to F.GOALS else 
         stat = @FALSE
         return stat
      end
      stat = @TRUE
      GoalRec = ''
      GoalRec<1> = name
      GoalRec<2> = owner
      GoalRec<3> = description
      ** Before writing, we should check "version" to be sure we aren't writing an older version on top of a newer version
      write GoalRec on F.GOALS, id ON ERROR
         stat = @FALSE
         logmsg \Error writing to GOALS for \:id:\ status: \:STATUS()
      end
      exists = (exists or stat) ;* If it already existed before, don't set to false
      return stat ;* Indicate we succeeded/failed to save
    END
    
    PUBLIC SUBROUTINE DELETE.OBJECT(status)
      status = @FALSE
      open 'GOALS' to F.GOALS then        
         if exists then
            * We'll have to do cleanup later on this. Cleanup anything associated with this user.
            delete F.GOALS, id
            exists = @FALSE        
            status = @TRUE 
         end
      end
    END

    PUBLIC SUBROUTINE SET.NAME(newName) 
      name = newName
      logmsg "set goal name ":newName
      return
    END
   
    PUBLIC FUNCTION GET.NAME()
      return name
    END

    PUBLIC SUBROUTINE SET.OWNER(newOwner) 
      owner = newOwner
      return
    END
   
    PUBLIC FUNCTION GET.OWNER()
      return owner
    END

    PUBLIC SUBROUTINE SET.DESCRIPTION(newDesc) 
      description = newDesc
      return
    END
   
    PUBLIC FUNCTION GET.DESCRIPTION()
      return description
    END

    PUBLIC FUNCTION GET.EXISTS()
      return exists
    END

    PUBLIC FUNCTION GET.ID()
      return id
    END

    PUBLIC FUNCTION TO.JSON()
      GoalInfo = Collection()
      if exists then
        GoalInfo{"id"} = id
        GoalInfo{"name"} = name
        GoalInfo{"owner"} = owner
        GoalInfo{"description"} = description
      END
      RETURN JBUILD(GoalInfo)
    END
END