$include keys.h
CLASS SESSION.B
    PRIVATE id, userId, createDate, createTime, exists
    PUBLIC SUBROUTINE CREATE.OBJECT(newId)
        open 'SESSIONS' to F.SESSIONS else exists = @FALSE
        read sessionRec from F.SESSIONS, newId then
            id = newId
            userId = sessionRec<1>
            createDate = sessionRec<2>
            createTime = sessionRec<3>
            exists = @TRUE
        end else
            id = SYSTEM(SYS$UUID)
            exists = @FALSE
            createDate = DATE()
            createTime = TIME()
        end
    END

    PUBLIC FUNCTION SAVE.OBJECT()
      open 'SESSIONS' to F.SESSIONS else 
         status = @FALSE
         return status
      end
      status = @TRUE
      sessionRec = ''
      sessionRec<1> = userId
      sessionRec<2> = createDate
      sessionRec<3> = createTime
      ** Before writing, we should check "version" to be sure we aren't writing an older version on top of a newer version
      write sessionRec on F.SESSIONS, id ON ERROR
         status = @FALSE
         logmsg \Error writing to SESSIONS for \:id:\ status: \:STATUS()
      end
      exists = (exists or status) ;* If it already existed before, don't set to false
      return status ;* Indicate we succeeded/failed to save
    END
    
    PUBLIC SUBROUTINE DELETE.OBJECT(status)
      status = @FALSE
      open 'SESSIONS' to F.SESSIONS then        
         if exists then
            * We'll have to do cleanup later on this. Cleanup anything associated with this user.
            delete F.SESSIONS, id
            exists = @FALSE        
            status = @TRUE 
         end
      end
    END

    PUBLIC SUBROUTINE SET.USERID(newUserId)
        if not(assigned(userId)) or userId = "" then 
            userId = newUserId
        END ELSE
            * Sessions can't change users
        END
    END

    PUBLIC FUNCTION GET.USERID()
        return userId
    END

    PUBLIC FUNCTION GET.EXISTS()
      return exists
    END

    PUBLIC FUNCTION GET.ID()
      return id
    END

    PUBLIC FUNCTION TO.COLLECTION()
        sessionInfo = Collection()
        if exists then
            sessionInfo{"id"} = id
            sessionInfo{"userId"} = userId
            sessionInfo{"createDate"} = oconv(createDate,"D4/")
            sessionInfo{"createTime"} = oconv(createTime,"MTHS")
        END

        return sessionInfo
    END

    PUBLIC FUNCTION TO.JSON()
      sessionInfo = ME->TO.COLLECTION()
      RETURN JBUILD(sessionInfo)
    END
END