REM demo 
REM flash args -L fpt,st,nt,c0,c1,...
REM fpt = frames per term
REM st = index (0-based) of starting term in sequence (-e arg)
REM nt = number of terms in sequence (-e arg) to use
REM c0 = color for sequence term label "0"
REM c1 = color for sequence term label "1"
%~dp0\..\bin\remote.exe 127.0.0.1 7000 fixstim -a -b gray -d 813 -e 01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101 -L 4,0,128,(0/0/0),(255/255/255)
