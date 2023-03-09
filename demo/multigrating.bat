REM Run a multi-orientation grating stimulus, using "--num-stim-pages=2", which sets up trials using 2 consecutive stimuli. 
REM Trigger "S" gets the first stim, and trigger "U" gets the second. Advance "a" gets you the third and fourth. 
rem You should see 4 gratings, one of which changes orientation on S/U. 
 
%~dp0\..\bin\remote.exe 127.0.0.1 7000 fixstim -f 0,0,1.0,red -b gray -d 813 -a -v -d 500 -f 0,0,.5,green --num-stim-pages=2 -s 0,0,3,3,100,.5,0,45,b,s,e  --multi-ori -4,4,0,4,4,45,-4,-4,90,4,-4,135!-4,4,0,4,4,45,-4,-4,90,4,-4,0!-4,4,0,4,4,45,-4,-4,90,4,-4,135!-4,4,0,4,4,45,-4,-4,0,4,-4,135!-4,4,0,4,4,45,-4,-4,90,4,-4,135!-4,4,0,4,4,0,-4,-4,90,4,-4,135!-4,4,0,4,4,45,-4,-4,90,4,-4,135!-4,4,45,4,4,0,-4,-4,0,4,-4,135
