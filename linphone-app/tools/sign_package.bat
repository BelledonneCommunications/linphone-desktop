set /p passphrase=<%1
%2 sign /f %3 /fd SHA256 /p %passphrase% /t %4 %5