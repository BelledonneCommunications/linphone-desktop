@echo off
if [%1]==[2] goto simple
set /p passphrase=<%2
%3 sign /f %4 /fd SHA256 /p %passphrase% /t %5 %6
goto :eof

:simple
%2 sign /fd SHA256 /t %3 /sha1 %4 %5

:eof
