subroutine CLEANUP.SESSIONS.B(sessionAge, cleanupStatus, cleanupStatusMessage)

open "SESSIONS" to F.SESSIONS else
    errorMessage = "Failed to read SESSIONS file."
    goto error
end

cleanupStatus = 1
cleanupStatusMessage = ""

currTimeDate = (DATE() * 86400) + TIME()
currTimeDateCutoff = currTimeDate - sessionAge
execute \select SESSIONS with createTimeDate < "\:currTimeDateCutoff:\"\

eof = 0
loop
    readnext sessionID else eof = 1
until eof do
    read sessionRec from F.SESSIONS, sessionID then
        delete F.SESSIONS, sessionID
    end
repeat

return 
***********
error:
cleanupStatus = 0
cleanupStatusMessage = errorMessage
return
end