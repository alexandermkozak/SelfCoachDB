crt 'User Name:'
input userName
crt 'Password:'
input password
subroutine AUTH.USER.B(userName, password, result, userInfo)
if result then
   crt "Success!"
end else
   crt "Fail!"
end
END
