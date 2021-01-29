crt 'User Name:'
input userName
crt 'Password:'
input password
call AUTH.USER.B(userName, password, result)
if result then
   crt "Success!"
end else
   crt "Fail!"
end
END
