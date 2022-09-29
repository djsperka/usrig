; $Id$
;

                SET    0.010,1,0       ;Get rate & scaling OK
                                       ;V1 is reward duration in ms
                VAR    V2=0            ;V2 logs whether the sequencer is in use for SafeSampleKey
                                       ;V3 determines whether juicer is open-high or open-low
                                       ;V4 is a voltage out variable for setting level on the opto
                                       ;V5 is used for rivalry, indicates time of stimulus change
                                       ;V6 is the number of pulses, for pulsed optogenetics
                                       ;V7 is the duration of the pulse, for pulsed optogenetics
                                       ;V8 is the interpulse interval, for pulsed optogenetics
                                       ;V9 is the pre-pulse stimulus duration, for pulsed opto
                                       ;V10 is the post-pulse stimulus duration, for pulsed opto
                                       ;V11 if not 0, duration of pulses on DIGLOW for INTAN system
                                       ;V12 holds clock-ticks representation of V11

; zero out all trigger lines, close juicer
0000 ZERO:  '0  MOVI   V2,1            ;Log that sequencer is in use
0001            BLT    V3,1,ZOPENHI    ;Branch, if V3 is 0, go to ZOPENHI
0002            DIGOUT [00000001]      ;Set juicer bit to closed (1 is closed)
0003            JUMP   ZERODONE        ;Jump over ZOPENHI to MOVI
0004 ZOPENHI:   DIGOUT [00000000]      ;Set juicer bit to closed (0 is closed)
0005 ZERODONE:  MOVI   V2,0            ;Log that sequencer is not in use
0006            HALT                   ;End of this sequence section


0007 FIXON: 'F  MOVI   V2,1            ;Log that sequencer is in use
0008            DIGOUT [......1.]      ;Signals the fixation point on
0009            BEQ    V5,1,VWAIT
0010            MOVI   V2,0            ;Log that sequencer is not in use
0011            HALT                   ;End of this sequence section

0012 FIXOFF: 'f MOVI   V2,1            ;Log that sequencer is in use
0013            DIGOUT [......0.]      ;Signals the fixation point off
0014            MOVI   V2,0            ;Log that sequencer is not in use
0015            HALT                   ;End of this sequence section

0016 STIMON: 'S MOVI   V2,1            ;Log that sequencer is in use
0017            DIGOUT [..0..1..]      ;Signals the stimuli on
0018            BEQ    V5,1,VWAIT
0019            MOVI   V2,0            ;Log that sequencer is not in use
0020            HALT                   ;End of this sequence section

0021 STIMOFF: 's MOVI  V2,1            ;Log that sequencer is in use
0022            DIGOUT [.....0..]      ;Signals the stimuli off
0023            MOVI   V2,0            ;Log that sequencer is not in use
0024            HALT                   ;End of this sequence section

0025 FXSTIMON: 'C MOVI V2,1            ;Log that sequencer is in use
0026            DIGOUT [.....11.]      ;Signals the stimulus and fixpt on
0027            BEQ    V5,1,VWAIT
0028            MOVI   V2,0            ;Log that sequencer is not in use
0029            HALT   

0030 STIMADV: 'a MOVI  V2,1            ;Log that sequencer is in use
0031            DIGOUT [....i...]      ;Signals the tuned parameter to advance
;                BEQ    V5,1,VWAIT     ;no branch for triggering, cmdline to fixstim should 
;                     ;omit 'a' from V arg, e.g. "-V 128,FS" , not "-V 128,FSa" or "-V 128"
0032            MOVI   V2,0            ;Log that sequencer is not in use
0033            HALT                   ;End of this sequence section

0034 TOGGHOLE: 'v MOVI V2,1            ;Log that sequencer is in use
0035            DIGOUT [..i.....]      ;Signals the tuned parameter to advance
0036            MOVI   V2,0            ;Log that sequencer is not in use
0037            HALT                   ;End of this sequence section

0038 TOGDONUT: 'u MOVI V2,1            ;Log that sequencer is in use
0039            DIGOUT [.i......]      ;Signals the tuned parameter to advance, this doesn't work
0040            MOVI   V2,0            ;Log that sequencer is not in use
0041            HALT                   ;End of this sequence section

0042 ALTSTIM: 'U MOVI  V2,1            ;Log that sequencer is in use
0043            DIGOUT [..1..0..]      ;Signals the tuned parameter to advance, this doesn't work
0044            MOVI   V2,0            ;Log that sequencer is not in use
0045            HALT                   ;End of this sequence section

0046 QUIT:  'Q  MOVI   V2,1            ;Log that sequencer is in use
0047            DIGOUT [...1....]      ;tells stim we are finished. Program should exit.
0048            MOVI   V2,0            ;Log that sequencer is not in use
0049            HALT                   ;End of this sequence section

0050 CLEAR: 'X  MOVI   V2,1            ;Log that sequencer is in use
0051            DIGOUT [..0..00.]      ;Clears fixation and stim triggers
;                                       DJS - include turning off U trigger.
;                BEQ    V5,1,VWAIT      ; no branch for triggering, cmdline to fixstim should 
;                       ;omit 'X' from V arg, e.g. "-V 128,FS" , not "-V 128,FSX" or "-V 128"
0052            MOVI   V2,0            ;Log that sequencer is not in use
0053            HALT                   ;End of this sequence section

0054 VWAIT:     WAIT   [......11]
0055 TRIGGER: 'V MOVI  V2,1            ;Log that sequencer is in use
0056            DIGOUT [1.......]      ;Trigger to present stim chg.
0057            DELAY  ms(50)
;                DELAY  ms(100)
0058            DIGOUT [0.......]
0059            MOVI   V2,0            ;Log that sequencer is not in use
0060            HALT                   ;End of this sequence section


; Reward
0061 REW:   'R  MOVI   V2,1            ;Log that sequencer is in use
0062            BLT    V3,1,REWHI      ;Branch, if V3 is 0, go to REWHI
0063            DIGOUT [.......1]      ;Assert that (LOW) juicer is closed
0064            DIGOUT [.......0]      ;Downward pulse delivers juice
0065            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0066            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0067            JUMP   RDONE           ;Jump to a HALT
0068 REWHI:     DIGOUT [.......0]      ;Assert that juicer is closed
0069            BLE    V1,0,RDONE      ;Skip if V1 is <= 0
0070            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0071            DIGOUT [.......1]      ;Voltage High delivers juice
0072            DELAY  V1              ;Delay V1 ms, duration of reward
0073            DIGOUT [.......0]      ;Close juicer valve
0074 RDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0075            HALT                   ;End of this sequence section

;Overly complicated code to use REWARD section to send INTAN pulse
;No longer needed, so simplified above, but keep this for easy 
;reversion just in case.
;0057 REW:   'R  MOVI   V2,1            ;Log that sequencer is in use
;0058            BLT    V3,1,REWHI      ;Branch, if V3 is 0, go to REWHI
;0059            DIGOUT [.......1]      ;Assert that (LOW) juicer is closed
;0060            BEQ    V11,1,RPLO      ;Branch, if V11 is 1 (INTAN), go to RPLO
;0061 REWRETLO:  DIGOUT [.......0]      ;Downward pulse delivers juice
;0062            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
;0063            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
;0064            JUMP   RDONE           ;Jump to a HALT
;0065 REWHI:     DIGOUT [.......0]      ;Assert that juicer is closed
;0066            BEQ    V11,1,RPHI      ;Branch, if V11 is 1 (INTAN), go to RPHI
;0067 REWRETHI:  BLE    V1,0,RDONE      ;Skip if V1 is <= 0
;0068            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
;0069            DIGOUT [.......1]      ;Voltage High delivers juice
;0070            DELAY  V1              ;Delay V1 ms, duration of reward
;0071            DIGOUT [.......0]      ;Close juicer valve
;0072            JUMP   RDONE
;0073 RPLO:      MARK   11              ;Indicate imminent reward delivery
;0074            DIGLOW [....1...]      ;Pulse for INTAN to indicate reward
;0075            DELAY  s(0.006)-1      ;Delay for 6 ms (trial-success pulse duration)
;0076            DIGLOW [....0...]      ;Pulse off
;0077            JUMP   REWRETLO        ;Jump to reward delivery for reward-low
;0078 RPHI:      MARK   11              ;Indicate imminent reward delivery
;0079            DIGLOW [....1...]      ;Pulse for INTAN to indicate reward
;0080            DELAY  s(0.006)-1      ;Delay for 6 ms (trial-success pulse duration)
;0081            DIGLOW [....0...]      ;Pulse off
;0082            JUMP   REWRETHI        ;Jump to reward delivery for reward-high
;0083 RDONE:     MOVI   V2,0            ;Log that sequencer is not in use
;0084            HALT                   ;End of this sequence section


; Reward, compatible with 'J'uicer command from Farran's rig, just do same thing as 'R'
0076 JCR:   'J  MOVI   V2,1            ;Log that sequencer is in use
0077            BLT    V3,1,JCRHI      ;Branch, if V3 is 0, go to JCRHI
0078            DIGOUT [.......1]      ;Assert that juicer is closed
0079            DIGOUT [.......0]      ;Downward pulse delivers juice
0080            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0081            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0082            JUMP   JDONE           ;Jump over JCRHI to a HALT
0083 JCRHI:     BLE    V1,0,JDONE      ;Skip if V1 is <= 0
0084            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0085            DIGOUT [.......0]      ;Assert that juicer is closed
0086            DIGOUT [.......1]      ;Voltage High delivers juice
0087            DELAY  V1              ;Delay V1 ms, duration of reward
0088            DIGOUT [.......0]      ;Close juicer valve
0089 JDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0090            HALT                   ;End of this sequence section


;Trial start, puts in a digital marker, and sends a DIGLOW pulse to INTAN system
0091 TRIAL: 'T  MOVI   V2,1            ;Log that sequencer is in use
0092            BEQ    V11,0,TDONE     ;Branch, if V11 is 0, go to TDONE
0093            MOV    V12,V11         ;Put value from V11 (ms pulse dur) into V12
0094            MULI   V12,ms(1)       ;convert V12 from ms to clock ticks
0095            ADDI   V12,-1          ;subtract one clock tick for precision
0096            MARK   V11             ;Mark onset of pulse with ms duration
0097            DIGLOW [....1...]      ;Pulse on
0098            DELAY  V12             ;Delay for V11 ms (requested pulse duration)
0099            DIGLOW [....0...]      ;Pulse off
0100 TDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0101            HALT                   ;End of this sequence section

;OLD version of T, keep until testing shows new version works
;0100 TRIAL: 'T  MOVI   V2,1            ;Log that sequencer is in use
;0101            MARK   55              ;Mark onset of trial
;0102            BLT    V11,1,TDONE     ;Branch, if V11 is 0, go to TDONE, don't pulse
;0103            DIGLOW [....1...]      ;Pulse for INTAN to indicate trial-start
;0104            DELAY  s(0.005)-1      ;Delay for 5 ms (trial-start pulse duration)
;0105            DIGLOW [....0...]      ;Pulse off
;0106 TDONE:     MOVI   V2,0            ;Log that sequencer is not in use
;0107            HALT                   ;End of this sequence section

; Simple optogenetics, just blanketing the stimulus 
0102 OPTOON: 'O MOVI   V2,1            ;Log that sequencer is in use
0103            DAC    0,V4            ;Set DAC0 to the value in V4
0104            MARK   1               ;Mark onset of laser on digital marker channel
0105            MOVI   V2,0            ;Log that sequencer is not in use
0106            HALT                   ;End of this sequence section

0107 OPTOOFF: 'o MOVI  V2,1            ;Log that sequencer is in use
0108            DAC    0,0             ;Set DAC0 to 0
0109            MARK   0               ;Mark offset of laser on digital marker channel
0110            MOVI   V2,0            ;Log that sequencer is not in use
0111            HALT                   ;End of this sequence section

0112 NOOPTO: 'N HALT                   ;Simply reserving this sequence to do nothing

0113 NOOPTOFF: 'n HALT                 ;Simply reserving this sequence to do nothing

; Complicated optogenetics, pulsing
0114 PULSOPTO: 'P MOVI V2,1            ;Log that sequencer is in use
0115            DIGOUT [.....1..]      ;Send stimulus on signal to VSG
0116 PDELAY:    DELAY  V9              ;Wait until first pulse on, subtract 1 tick
0117 PULSEON:   DAC    0,V4            ;Set DAC0 to the value in V4
0118            MARK   1               ;Mark onset of laser on digital marker channel
0119            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0120            DAC    0,0             ;Set DAC0 to 0
0121            MARK   0               ;Mark offset of laser on digital marker channel
0122            DBNZ   V6,PULSEIPI     ;Decrement #pulses, go to IPI if more
0123            JUMP   PULSEXIT        ;Jump to wait/exit from pulse/stim
0124 PULSEIPI:  BLT    V6,0,PULSEXIT   ;Failsafe, if <0 get out before infinite decrement
0125            DELAY  V8              ;Wait through IPI, subtract 4 ticks
0126            JUMP   PULSEON         ;Start next pulse
0127 PULSEXIT:  DELAY  V10             ;Wait until stim should go off, subtract 3 ticks
0128            DIGOUT [.....0..]      ;Signals the stimuli off
0129            MOVI   V2,0            ;Log that sequencer is not in use
0130            HALT                   ;End of this sequence section

; Simpler opto/e-stim, gives one pulse
0131 ONEPING: 'p MOVI  V2,1            ;Log that sequencer is in use
0132            DAC    0,V4            ;Set DAC0 to the value in V4
0133            MARK   1               ;Mark onset of laser on digital marker channel
0134            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0135            DAC    0,0             ;Set DAC0 to 0
0136            MARK   0               ;Mark offset of laser on digital marker channel
0137            MOVI   V2,0            ;Log that sequencer is not in use
0138            HALT                   ;End of this sequence section


; Abort for pulsing optgenetics, cannot use SafeSampleKey to call this
0139 PULSABRT: 'B DAC  0,0             ;Set DAC0 to 0
0140            MARK   0               ;Mark offset of laser on digital marker channel
0141            DIGOUT [.....0..]      ;Signals the stimuli off
0142            MOVI   V2,0            ;Log that sequencer is not in use
0143            HALT                   ;End of this sequence section

; LED commands for fixation LED - these were for Ben, DIGLOWS now for ASL file 
;     LEDON:  'L MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [1.......]      ;Turn on LED - don't know which digout yet
;                JUMP   LDONE           ;Jump over LEDOFF to a HALT
;     LEDOFF: 'M MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [0.......]      ;Turn off LED - don't know which digout yet
;     LDONE:     MOVI   V2,0            ;Log that sequencer is not in use
;                HALT                   ;End of this sequence section


; zero out all DIGLOW lines
0144 ZEROLOW: 'Z MOVI  V2,1            ;Log that sequencer is in use
0145            DIGLOW [00000000]
0146            MOVI   V2,0            ;Log that sequencer is not in use
0147            HALT   

; give heartbeat 1 pulse
0148 HB1:   '1  MOVI   V2,1            ;Log that sequencer is in use
0149            DIGLOW [.....001]
0150            MARK   101             ;Mark heartbeat on digital marker channel
;0130            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0131            DIGLOW [.......0]
0151            MOVI   V2,0            ;Log that sequencer is not in use
0152            HALT   

; give heartbeat 2 pulse
0153 HB2:   '2  MOVI   V2,1            ;Log that sequencer is in use
0154            DIGLOW [.....010]
0155            MARK   102             ;Mark heartbeat on digital marker channel
;0137            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0138            DIGLOW [......0.]
0156            MOVI   V2,0            ;Log that sequencer is not in use
0157            HALT   

; give heartbeat 3 pulse
0158 HB3:   '3  MOVI   V2,1            ;Log that sequencer is in use
0159            DIGLOW [.....011]
0160            MARK   103             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [......00]
0161            MOVI   V2,0            ;Log that sequencer is not in use
0162            HALT   

; give heartbeat 4 pulse
0163 HB4:   '4  MOVI   V2,1            ;Log that sequencer is in use
0164            DIGLOW [.....100]
0165            MARK   104             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0..]
0166            MOVI   V2,0            ;Log that sequencer is not in use
0167            HALT   

; give heartbeat 5 pulse
0168 HB5:   '5  MOVI   V2,1            ;Log that sequencer is in use
0169            DIGLOW [.....101]
0170            MARK   105             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0.0]
0171            MOVI   V2,0            ;Log that sequencer is not in use
0172            HALT   

; give heartbeat 6 pulse
0173 HB6:   '6  MOVI   V2,1            ;Log that sequencer is in use
0174            DIGLOW [.....110]
0175            MARK   106             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....00.]
0176            MOVI   V2,0            ;Log that sequencer is not in use
0177            HALT   

; give heartbeat 7 pulse
0178 HB7:   '7  MOVI   V2,1            ;Log that sequencer is in use
0179            DIGLOW [.....111]
0180            MARK   107             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....000]
0181            MOVI   V2,0            ;Log that sequencer is not in use
0182            HALT   


; Tell ASL to open file for output (and force marker bits low)
0183 ASLOPEN: 'I MOVI  V2,1            ;Log that sequencer is in use
0184            DIGLOW [.1...000]      ;open file, XDAT bit 6
0185            MOVI   V2,0            ;Log that sequencer is not in use
0186            HALT   

; Tell ASL to close output file (and force marker bits low)
0187 ASLCLOSE: 'i MOVI V2,1            ;Log that sequencer is in use
0188            DIGLOW [.0...000]      ;close file
0189            MOVI   V2,0            ;Log that sequencer is not in use
0190            HALT   

; Tell ASL to start recording to open output file (and force marker bits low)
0191 ASLREC: 'W MOVI   V2,1            ;Log that sequencer is in use
0192            DIGLOW [..1..000]      ;start recording, XDAT bit 5 (7 no worky)
0193            MOVI   V2,0            ;Log that sequencer is not in use
0194            HALT   

; Tell ASL to stop recording; do not close output file (and force marker bits low)
0195 ASLSTOPR: 'w MOVI V2,1            ;Log that sequencer is in use
0196            DIGLOW [..0..000]      ;stop recording, XDAT bit 5 (7 no worky)
0197            MOVI   V2,0            ;Log that sequencer is not in use
0198            HALT