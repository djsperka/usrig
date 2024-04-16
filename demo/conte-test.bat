REM Demo of conte stim. Uses auto-generated dot patches, and a trials file in this folder. 
REM Run from a CommandPrompt window in the folder where this bat file lives.
REM Use triggers F,S,X,a in fixstim server window.
%~dp0\..\bin\remote.exe 127.0.0.1 7000 conte -v -a -b gray -d 600 -p 4 -f +,-9,-9,1,black,2,0 -c red -c green --show-cue-rects --trials %~dp0\conte-trials.csv --generate-dots 50 --show-aperture
