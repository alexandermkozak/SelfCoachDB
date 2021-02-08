$include keys.h

open "SYSCONFIGS" to F.SYSCONFIGS else
   goto error
end

start.loop:
read configRec from F.SYSCONFIGS, "SESSION" then
    sleepDuration = configRec<1>
    sessionAge = configRec<2>
    if sleepDuration = "" or sleepDuration <= 0 then
        goto error
    end
    TRY
        call CLEANUP.SESSIONS.B(sessionAge, cleanupStatus, cleanupStatusMessage)
        if not(cleanupStatus) then
            errorMessage = cleanupStatusMessage
            goto error
        end
    CATCH SYS$ANY
        errorMessage = @EXCEPTION.DATA
        goto error
    END
    sleep sleepDuration
    goto start.loop
end
STOP
***********
error:
LOGMSG "Error in SESSION.KILLER.B: ":errorMessage
STOP
end
