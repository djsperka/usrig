REM demo of box-of-parameters with a single grating. The varying parameters are Orientation (-O), Contrast (-C), and fixpt color (-U). 
%~dp0\..\bin\remote.exe 127.0.0.1 7000 starstim -a -f +,0,0,1.0,black,3,0 -b gray -d 813 -g 5,0,4,4,100,0.2,.25,0,0,b,s,e -g 5,0,4,4,100,0.5,.5,90,0,b,s,e -g 5,0,4,4,100,0.5,1.0,45,0,b,q,e -o 2,1,0
rem -s -5,5,4,4,100,0.2,.25,0,0,b,s,e -O 0,45,90,135,180 -C 20,40,60,80,100 -U (255/127/55),(55/127/255),[.2/.5/.9],green
REM -f 0,0,1.0,red
rem +,0,0,1.0,black,3,0
