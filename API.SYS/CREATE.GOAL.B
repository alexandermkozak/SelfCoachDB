SUBROUTINE CREATE.GOAL.B(goalCollection, goal, goalStatus)
goalId = ''
goalStatus = @FALSE

if ELEMENT.EXISTS(goalCollection{"name"}) then
   goal->SET.NAME(goalCollection{'name'})
end
if ELEMENT.EXISTS(goalCollection{"description"}) then
   goal->SET.DESCRIPTION(goalCollection{'description'})
end
if ELEMENT.EXISTS(goalCollection{"owner"}) then
   goal->SET.OWNER(goalCollection{'owner'})
end

if goal->GET.OWNER() = "" or goal->GET.NAME() = "" then
    goto fail
end else
    logmsg "goal name ":goal->GET.NAME()
    goalStatus = goal->SAVE.OBJECT()
end


RETURN
****
fail:
logmsg "Failed to create Goal!"
RETURN
END