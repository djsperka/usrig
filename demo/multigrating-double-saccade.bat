REM Run a multi-orientation grating stimulus, using "--num-stim-pages=2", which sets up trials using 2 consecutive stimuli. 
REM Trigger "S" gets the first stim, and trigger "U" gets the second. Advance "a" gets you the third and fourth. 
rem You should see 4 gratings, one of which changes orientation on S/U. 
 
%~dp0\..\bin\remote.exe 127.0.0.1 7000 fixstim -f 0,0,1.0,red -b gray -d 813 -a -v -d 500 -f 0,0,.5,green -s -6,-5,5,5,100,.5,.1,45,b,s,e -O 0,45,90 --draw-group 2 -s -6,5,5,5,100,.5,.2,180,b,s,e -C 25,50,75
