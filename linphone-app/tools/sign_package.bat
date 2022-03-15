@echo off
if [%5]==[] goto simple
set /p passphrase=<%1
%2 sign /f %3 /fd SHA256 /p %passphrase% /t %4 %5
goto :eof

:simple
%1 sign /fd SHA256 /t %2 %3

:eof
