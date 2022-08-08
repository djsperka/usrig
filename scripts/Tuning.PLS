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
0017            DIGOUT [.....1..]      ;Signals the stimuli on
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

0042 QUIT:  'Q  MOVI   V2,1            ;Log that sequencer is in use
0043            DIGOUT [...1....]      ;tells stim we are finished. Program should exit.
0044            MOVI   V2,0            ;Log that sequencer is not in use
0045            HALT                   ;End of this sequence section

0046 CLEAR: 'X  MOVI   V2,1            ;Log that sequencer is in use
0047            DIGOUT [.....00.]      ;Clears fixation and stim triggers
;                BEQ    V5,1,VWAIT      ; no branch for triggering, cmdline to fixstim should 
;                       ;omit 'X' from V arg, e.g. "-V 128,FS" , not "-V 128,FSX" or "-V 128"
0048            MOVI   V2,0            ;Log that sequencer is not in use
0049            HALT                   ;End of this sequence section

0050 VWAIT:     WAIT   [......11]
0051 TRIGGER: 'V MOVI  V2,1            ;Log that sequencer is in use
0052            DIGOUT [1.......]      ;Trigger to present stim chg.
0053            DELAY  ms(50)
;                DELAY  ms(100)
0054            DIGOUT [0.......]
0055            MOVI   V2,0            ;Log that sequencer is not in use
0056            HALT                   ;End of this sequence section


; Reward
0057 REW:   'R  MOVI   V2,1            ;Log that sequencer is in use
0058            BLT    V3,1,REWHI      ;Branch, if V3 is 0, go to REWHI
0059            DIGOUT [.......1]      ;Assert that (LOW) juicer is closed
0060            DIGOUT [.......0]      ;Downward pulse delivers juice
0061            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0062            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0063            JUMP   RDONE           ;Jump to a HALT
0064 REWHI:     DIGOUT [.......0]      ;Assert that juicer is closed
0065            BLE    V1,0,RDONE      ;Skip if V1 is <= 0
0066            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0067            DIGOUT [.......1]      ;Voltage High delivers juice
0068            DELAY  V1              ;Delay V1 ms, duration of reward
0069            DIGOUT [.......0]      ;Close juicer valve
0070 RDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0071            HALT                   ;End of this sequence section

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
0072 JCR:   'J  MOVI   V2,1            ;Log that sequencer is in use
0073            BLT    V3,1,JCRHI      ;Branch, if V3 is 0, go to JCRHI
0074            DIGOUT [.......1]      ;Assert that juicer is closed
0075            DIGOUT [.......0]      ;Downward pulse delivers juice
0076            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0077            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0078            JUMP   JDONE           ;Jump over JCRHI to a HALT
0079 JCRHI:     BLE    V1,0,JDONE      ;Skip if V1 is <= 0
0080            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0081            DIGOUT [.......0]      ;Assert that juicer is closed
0082            DIGOUT [.......1]      ;Voltage High delivers juice
0083            DELAY  V1              ;Delay V1 ms, duration of reward
0084            DIGOUT [.......0]      ;Close juicer valve
0085 JDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0086            HALT                   ;End of this sequence section


;Trial start, puts in a digital marker, and sends a DIGLOW pulse to INTAN system
0087 TRIAL: 'T  MOVI   V2,1            ;Log that sequencer is in use
0088            BEQ    V11,0,TDONE     ;Branch, if V11 is 0, go to TDONE
0089            MOV    V12,V11         ;Put value from V11 (ms pulse dur) into V12
0090            MULI   V12,ms(1)       ;convert V12 from ms to clock ticks
0091            ADDI   V12,-1          ;subtract one clock tick for precision
0092            MARK   V11             ;Mark onset of pulse with ms duration
0093            DIGLOW [....1...]      ;Pulse on
0094            DELAY  V12             ;Delay for V11 ms (requested pulse duration)
0095            DIGLOW [....0...]      ;Pulse off
0096 TDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0097            HALT                   ;End of this sequence section

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
0098 OPTOON: 'O MOVI   V2,1            ;Log that sequencer is in use
0099            DAC    0,V4            ;Set DAC0 to the value in V4
0100            MARK   1               ;Mark onset of laser on digital marker channel
0101            MOVI   V2,0            ;Log that sequencer is not in use
0102            HALT                   ;End of this sequence section

0103 OPTOOFF: 'o MOVI  V2,1            ;Log that sequencer is in use
0104            DAC    0,0             ;Set DAC0 to 0
0105            MARK   0               ;Mark offset of laser on digital marker channel
0106            MOVI   V2,0            ;Log that sequencer is not in use
0107            HALT                   ;End of this sequence section

0108 NOOPTO: 'N HALT                   ;Simply reserving this sequence to do nothing

0109 NOOPTOFF: 'n HALT                 ;Simply reserving this sequence to do nothing

; Complicated optogenetics, pulsing
0110 PULSOPTO: 'P MOVI V2,1            ;Log that sequencer is in use
0111            DIGOUT [.....1..]      ;Send stimulus on signal to VSG
0112 PDELAY:    DELAY  V9              ;Wait until first pulse on, subtract 1 tick
0113 PULSEON:   DAC    0,V4            ;Set DAC0 to the value in V4
0114            MARK   1               ;Mark onset of laser on digital marker channel
0115            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0116            DAC    0,0             ;Set DAC0 to 0
0117            MARK   0               ;Mark offset of laser on digital marker channel
0118            DBNZ   V6,PULSEIPI     ;Decrement #pulses, go to IPI if more
0119            JUMP   PULSEXIT        ;Jump to wait/exit from pulse/stim
0120 PULSEIPI:  BLT    V6,0,PULSEXIT   ;Failsafe, if <0 get out before infinite decrement
0121            DELAY  V8              ;Wait through IPI, subtract 4 ticks
0122            JUMP   PULSEON         ;Start next pulse
0123 PULSEXIT:  DELAY  V10             ;Wait until stim should go off, subtract 3 ticks
0124            DIGOUT [.....0..]      ;Signals the stimuli off
0125            MOVI   V2,0            ;Log that sequencer is not in use
0126            HALT                   ;End of this sequence section

; Simpler opto/e-stim, gives one pulse
0127 ONEPING: 'p MOVI  V2,1            ;Log that sequencer is in use
0128            DAC    0,V4            ;Set DAC0 to the value in V4
0129            MARK   1               ;Mark onset of laser on digital marker channel
0130            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0131            DAC    0,0             ;Set DAC0 to 0
0132            MARK   0               ;Mark offset of laser on digital marker channel
0133            MOVI   V2,0            ;Log that sequencer is not in use
0134            HALT                   ;End of this sequence section


; Abort for pulsing optgenetics, cannot use SafeSampleKey to call this
0135 PULSABRT: 'B DAC  0,0             ;Set DAC0 to 0
0136            MARK   0               ;Mark offset of laser on digital marker channel
0137            DIGOUT [.....0..]      ;Signals the stimuli off
0138            MOVI   V2,0            ;Log that sequencer is not in use
0139            HALT                   ;End of this sequence section

; LED commands for fixation LED - these were for Ben, DIGLOWS now for ASL file 
;     LEDON:  'L MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [1.......]      ;Turn on LED - don't know which digout yet
;                JUMP   LDONE           ;Jump over LEDOFF to a HALT
;     LEDOFF: 'M MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [0.......]      ;Turn off LED - don't know which digout yet
;     LDONE:     MOVI   V2,0            ;Log that sequencer is not in use
;                HALT                   ;End of this sequence section


; zero out all DIGLOW lines
0140 ZEROLOW: 'Z MOVI  V2,1            ;Log that sequencer is in use
0141            DIGLOW [00000000]
0142            MOVI   V2,0            ;Log that sequencer is not in use
0143            HALT   

; give heartbeat 1 pulse
0144 HB1:   '1  MOVI   V2,1            ;Log that sequencer is in use
0145            DIGLOW [.....001]
0146            MARK   101             ;Mark heartbeat on digital marker channel
;0130            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0131            DIGLOW [.......0]
0147            MOVI   V2,0            ;Log that sequencer is not in use
0148            HALT   

; give heartbeat 2 pulse
0149 HB2:   '2  MOVI   V2,1            ;Log that sequencer is in use
0150            DIGLOW [.....010]
0151            MARK   102             ;Mark heartbeat on digital marker channel
;0137            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0138            DIGLOW [......0.]
0152            MOVI   V2,0            ;Log that sequencer is not in use
0153            HALT   

; give heartbeat 3 pulse
0154 HB3:   '3  MOVI   V2,1            ;Log that sequencer is in use
0155            DIGLOW [.....011]
0156            MARK   103             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [......00]
0157            MOVI   V2,0            ;Log that sequencer is not in use
0158            HALT   

; give heartbeat 4 pulse
0159 HB4:   '4  MOVI   V2,1            ;Log that sequencer is in use
0160            DIGLOW [.....100]
0161            MARK   104             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0..]
0162            MOVI   V2,0            ;Log that sequencer is not in use
0163            HALT   

; give heartbeat 5 pulse
0164 HB5:   '5  MOVI   V2,1            ;Log that sequencer is in use
0165            DIGLOW [.....101]
0166            MARK   105             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0.0]
0167            MOVI   V2,0            ;Log that sequencer is not in use
0168            HALT   

; give heartbeat 6 pulse
0169 HB6:   '6  MOVI   V2,1            ;Log that sequencer is in use
0170            DIGLOW [.....110]
0171            MARK   106             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....00.]
0172            MOVI   V2,0            ;Log that sequencer is not in use
0173            HALT   

; give heartbeat 7 pulse
0174 HB7:   '7  MOVI   V2,1            ;Log that sequencer is in use
0175            DIGLOW [.....111]
0176            MARK   107             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....000]
0177            MOVI   V2,0            ;Log that sequencer is not in use
0178            HALT   


; Tell ASL to open file for output (and force marker bits low)
0179 ASLOPEN: 'I MOVI  V2,1            ;Log that sequencer is in use
0180            DIGLOW [.1...000]      ;open file, XDAT bit 6
0181            MOVI   V2,0            ;Log that sequencer is not in use
0182            HALT   

; Tell ASL to close output file (and force marker bits low)
0183 ASLCLOSE: 'i MOVI V2,1            ;Log that sequencer is in use
0184            DIGLOW [.0...000]      ;close file
0185            MOVI   V2,0            ;Log that sequencer is not in use
0186            HALT   

; Tell ASL to start recording to open output file (and force marker bits low)
0187 ASLREC: 'W MOVI   V2,1            ;Log that sequencer is in use
0188            DIGLOW [..1..000]      ;start recording, XDAT bit 5 (7 no worky)
0189            MOVI   V2,0            ;Log that sequencer is not in use
0190            HALT   

; Tell ASL to stop recording; do not close output file (and force marker bits low)
0191 ASLSTOPR: 'w MOVI V2,1            ;Log that sequencer is in use
0192            DIGLOW [..0..000]      ;stop recording, XDAT bit 5 (7 no worky)
0193            MOVI   V2,0            ;Log that sequencer is not in use
0194            HALT