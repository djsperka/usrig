REM Run a multi-orientation grating stimulus, using "--num-stim-pages=2", which sets up trials using 2 consecutive stimuli. 
REM Trigger "S" gets the first stim, and trigger "U" gets the second. Advance "a" gets you the third and fourth. 
rem You should see 4 gratings, one of which changes orientation on S/U. 
 
%~dp0\..\bin\remote.exe 127.0.0.1 7000 fixstim -a -f -8,0,0.5,blue -b gray -d 800 -p 2  -v  -s 4.0,4.0,2.0,2.0,0.0,0.0,100,1.00,1.00,90.0,0.0,b,ss,e,0.00 -O 45,50,55 --draw-group 2 -s 7.0,7.0,2.0,2.0,0.0,0.0,100,1.00,1.00,180.0,0.0,b,ss,e,0.00
