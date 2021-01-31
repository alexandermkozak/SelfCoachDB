SUBROUTINE CREATE.SESSION.B(user, session, sessionStatus, sessionStatusMessage)
sessionStatus = @FALSE
session = OBJECT("SESSION.B", "")
session->SET.USERID(user->GET.USERNAME())
createStatus = session->SAVE.OBJECT()

if createStatus = @TRUE then
    sessionStatus = @TRUE
END ELSE
    sessionStatusMessage = "SessionCreationFailed"
    goto error
END

RETURN
********************
error:
session = ""
sessionStatus = @FALSE
RETURN
********************
END