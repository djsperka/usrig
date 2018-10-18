; $Id$
;

                SET    0.010,1,0       ;Get rate & scaling OK
                VAR    V1=0            ;V1 holds whether we are currently pulsing or not
                                       ;V3 holds the number of ticks per cycle
                                       ;V4 is a voltage out variable for setting level on the opto
                                       ;V5 is the duty cycle, in percent
                VAR    V6=2            ;V6 is 2, for DIV math (AND accounting for some clock ticks)
                                       ;V7 is the duration of the pulse, in ticks
                                       ;V8 is the interpulse interval, in ticks
                VAR    V9=100          ;V9 is 100, for DIV math
                VAR    V10=3           ;V10 is 3, to account for some clock ticks

0000 QUIT:  'Q  DAC    0,0             ;Set DAC0 to 0
0001            MARK   0               ;Mark offset of laser on digital marker channel
0002            HALT   

0003 FREQUP: 'U DAC    0,0             ;Set DAC0 to 0
0004            MARK   0               ;Mark offset of laser on digital marker channel
0005            BLT    V3,6250,DOCALC  ;If cycles per second is less than 6250, don't change
0006            DIV    V3,V6           ;Reduce cycles per second by factor of 2
0007            JUMP   DOCALC          ;Jump to pulse ticks calculation
0008            HALT   

0009 FREQDOWN: 'D DAC  0,0             ;Set DAC0 to 0
0010            MARK   0               ;Mark offset of laser on digital marker channel
0011            BGT    V3,400000,DOCALC ;If cycles per second is greater than 400000, don't change
0012            MULI   V3,2            ;Increase cycles per second by 2
0013            JUMP   DOCALC          ;Jump to pulse ticks calculation
0014            HALT   

0015 DOCALC: 'C MOV    V7,V3           ;Put ticks per cycle into V7
0016            MUL    V7,V5           ;Calculate 100*duration of pulse in cycles
0017            DIV    V7,V9           ;Calculate actual duration of pulse in cycles
0018            MOV    V8,V3           ;Put ticks per cycle into V8
0019            SUB    V8,V7           ;Calculate duration of interpulse in cycles
0020            SUB    V7,V6           ;Subtract two ticks from pulse duration for clock operations
0021            SUB    V8,V10          ;Subtract three ticks from IP duration for clock operations
0022            BEQ    V1,1,PULSEON    ;If we are currently pulsing go to PULSEON
0023            HALT   


0024 PULSEON: 'O MOVI  V1,1            ;Mark that pulsing is happening
0025 PSTILLON:  DAC    0,V4            ;Set DAC0 to the value in V4
0026            MARK   1               ;Mark onset of laser on digital marker channel
0027            DELAY  V7              ;Wait until pulse off time
0028            DAC    0,0             ;Set DAC0 to 0
0029            MARK   0               ;Mark offset of laser on digital marker channel
0030 PULSEIPI:  DELAY  V8              ;Wait through IPI
0031            JUMP   PSTILLON        ;Start next pulse
0032            HALT   

0033 PULSEOFF: 'X MOVI V1,0            ;Mark that pulsing is off
0034            DAC    0,0             ;Set DAC0 to 0
0035            MARK   0               ;Mark offset of laser on digital marker channel
0036            HALT