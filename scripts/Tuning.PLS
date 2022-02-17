; $Id$
;

                SET    0.010,1,0       ;Get rate & scaling OK
                VAR    V2=0            ;V2 logs whether the sequencer is in use for SafeSampleKey
                                       ;V3 determines whether juicer is open-high or open-low
                                       ;V4 is a voltage out variable for setting level on the opto
                                       ;V5 is used for rivalry, indicates time of stimulus change
                                       ;V6 is the number of pulses, for pulsed optogenetics
                                       ;V7 is the duration of the pulse, for pulsed optogenetics
                                       ;V8 is the interpulse interval, for pulsed optogenetics
                                       ;V9 is the pre-pulse stimulus duration, for pulsed opto
                                       ;V10 is the post-pulse stimulus duration, for pulsed opto
                                       ;V11 if 1 send reward/trial pulses on DIGLOW for INTAN system

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
0060            BEQ    V11,1,RPLO      ;Branch, if V11 is 1 (INTAN), go to RPLO
0061 REWRETLO:  DIGOUT [.......0]      ;Downward pulse delivers juice
0062            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0063            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0064            JUMP   RDONE           ;Jump to a HALT
0065 REWHI:     DIGOUT [.......0]      ;Assert that juicer is closed
0066            BEQ    V11,1,RPHI      ;Branch, if V11 is 1 (INTAN), go to RPHI
0067 REWRETHI:  BLE    V1,0,RDONE      ;Skip if V1 is <= 0
0068            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0069            DIGOUT [.......1]      ;Voltage High delivers juice
0070            DELAY  V1              ;Delay V1 ms, duration of reward
0071            DIGOUT [.......0]      ;Close juicer valve
0072            JUMP   RDONE
0073 RPLO:      MARK   11              ;Indicate imminent reward delivery
0074            DIGLOW [....1...]      ;Pulse for INTAN to indicate reward
0075            DELAY  s(0.006)-1      ;Delay for 6 ms to indicate trial-success
0076            DIGLOW [....0...]      ;Pulse off
0077            JUMP   REWRETLO        ;Jump to reward delivery for reward-low
0078 RPHI:      MARK   11              ;Indicate imminent reward delivery
0079            DIGLOW [....1...]      ;Pulse for INTAN to indicate reward
0080            DELAY  s(0.006)-1      ;Delay for 6 ms to indiacte trial-success
0081            DIGLOW [....0...]      ;Pulse off
0082            JUMP   REWRETHI        ;Jump to reward delivery for reward-high
0083 RDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0084            HALT                   ;End of this sequence section

; Reward, compatible with 'J'uicer command from Farran's rig, just do same thing as 'R'
0085 JCR:   'J  MOVI   V2,1            ;Log that sequencer is in use
0086            BLT    V3,1,JCRHI      ;Branch, if V3 is 0, go to JCRHI
0087            DIGOUT [.......1]      ;Assert that juicer is closed
0088            DIGOUT [.......0]      ;Downward pulse delivers juice
0089            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0090            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0091            JUMP   JDONE           ;Jump over JCRHI to a HALT
0092 JCRHI:     BLE    V1,0,JDONE      ;Skip if V1 is <= 0
0093            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0094            DIGOUT [.......0]      ;Assert that juicer is closed
0095            DIGOUT [.......1]      ;Voltage High delivers juice
0096            DELAY  V1              ;Delay V1 ms, duration of reward
0097            DIGOUT [.......0]      ;Close juicer valve
0098 JDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0099            HALT                   ;End of this sequence section


;Trial start, puts in a digital marker, and sends a DIGLOW pulse to INTAN system
0100 TRIAL: 'T  MOVI   V2,1            ;Log that sequencer is in use
0101            MARK   55              ;Mark onset of trial
0102            BLT    V3,11,TDONE     ;Branch, if V11 is 0, go to TDONE, don't pulse
0103            DIGLOW [....1...]      ;Pulse for INTAN to indicate reward
0104            DELAY  s(0.005)-1      ;Delay for 5 ms to indiacte trial-start
0105            DIGLOW [....0...]      ;Pulse off
0106 TDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0107            HALT                   ;End of this sequence section

; Simple optogenetics, just blanketing the stimulus 
0108 OPTOON: 'O MOVI   V2,1            ;Log that sequencer is in use
0109            DAC    0,V4            ;Set DAC0 to the value in V4
0110            MARK   1               ;Mark onset of laser on digital marker channel
0111            MOVI   V2,0            ;Log that sequencer is not in use
0112            HALT                   ;End of this sequence section

0113 OPTOOFF: 'o MOVI  V2,1            ;Log that sequencer is in use
0114            DAC    0,0             ;Set DAC0 to 0
0115            MARK   0               ;Mark offset of laser on digital marker channel
0116            MOVI   V2,0            ;Log that sequencer is not in use
0117            HALT                   ;End of this sequence section

0118 NOOPTO: 'N HALT                   ;Simply reserving this sequence to do nothing

0119 NOOPTOFF: 'n HALT                 ;Simply reserving this sequence to do nothing

; Complicated optogenetics, pulsing
0120 PULSOPTO: 'P MOVI V2,1            ;Log that sequencer is in use
0121            DIGOUT [.....1..]      ;Send stimulus on signal to VSG
0122 PDELAY:    DELAY  V9              ;Wait until first pulse on, subtract 1 tick
0123 PULSEON:   DAC    0,V4            ;Set DAC0 to the value in V4
0124            MARK   1               ;Mark onset of laser on digital marker channel
0125            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0126            DAC    0,0             ;Set DAC0 to 0
0127            MARK   0               ;Mark offset of laser on digital marker channel
0128            DBNZ   V6,PULSEIPI     ;Decrement #pulses, go to IPI if more
0129            JUMP   PULSEXIT        ;Jump to wait/exit from pulse/stim
0130 PULSEIPI:  DELAY  V8              ;Wait through IPI, subtract 3 ticks
0131            JUMP   PULSEON         ;Start next pulse
0132 PULSEXIT:  DELAY  V10             ;Wait until stim should go off, subtract 3 ticks
0133            DIGOUT [.....0..]      ;Signals the stimuli off
0134            MOVI   V2,0            ;Log that sequencer is not in use
0135            HALT                   ;End of this sequence section

; Simpler opto/e-stim, gives one pulse
0136 ONEPING: 'p MOVI  V2,1            ;Log that sequencer is in use
0137            DAC    0,V4            ;Set DAC0 to the value in V4
0138            MARK   1               ;Mark onset of laser on digital marker channel
0139            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0140            DAC    0,0             ;Set DAC0 to 0
0141            MARK   0               ;Mark offset of laser on digital marker channel
0142            MOVI   V2,0            ;Log that sequencer is not in use
0143            HALT                   ;End of this sequence section


; Abort for pulsing optgenetics, cannot use SafeSampleKey to call this
0144 PULSABRT: 'B DAC  0,0             ;Set DAC0 to 0
0145            MARK   0               ;Mark offset of laser on digital marker channel
0146            DIGOUT [.....0..]      ;Signals the stimuli off
0147            MOVI   V2,0            ;Log that sequencer is not in use
0148            HALT                   ;End of this sequence section

; LED commands for fixation LED - these were for Ben, DIGLOWS now for ASL file 
;     LEDON:  'L MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [1.......]      ;Turn on LED - don't know which digout yet
;                JUMP   LDONE           ;Jump over LEDOFF to a HALT
;     LEDOFF: 'M MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [0.......]      ;Turn off LED - don't know which digout yet
;     LDONE:     MOVI   V2,0            ;Log that sequencer is not in use
;                HALT                   ;End of this sequence section


; zero out all DIGLOW lines
0149 ZEROLOW: 'Z MOVI  V2,1            ;Log that sequencer is in use
0150            DIGLOW [00000000]
0151            MOVI   V2,0            ;Log that sequencer is not in use
0152            HALT   

; give heartbeat 1 pulse
0153 HB1:   '1  MOVI   V2,1            ;Log that sequencer is in use
0154            DIGLOW [.....001]
0155            MARK   101             ;Mark heartbeat on digital marker channel
;0130            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0131            DIGLOW [.......0]
0156            MOVI   V2,0            ;Log that sequencer is not in use
0157            HALT   

; give heartbeat 2 pulse
0158 HB2:   '2  MOVI   V2,1            ;Log that sequencer is in use
0159            DIGLOW [.....010]
0160            MARK   102             ;Mark heartbeat on digital marker channel
;0137            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0138            DIGLOW [......0.]
0161            MOVI   V2,0            ;Log that sequencer is not in use
0162            HALT   

; give heartbeat 3 pulse
0163 HB3:   '3  MOVI   V2,1            ;Log that sequencer is in use
0164            DIGLOW [.....011]
0165            MARK   103             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [......00]
0166            MOVI   V2,0            ;Log that sequencer is not in use
0167            HALT   

; give heartbeat 4 pulse
0168 HB4:   '4  MOVI   V2,1            ;Log that sequencer is in use
0169            DIGLOW [.....100]
0170            MARK   104             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0..]
0171            MOVI   V2,0            ;Log that sequencer is not in use
0172            HALT   

; give heartbeat 5 pulse
0173 HB5:   '5  MOVI   V2,1            ;Log that sequencer is in use
0174            DIGLOW [.....101]
0175            MARK   105             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0.0]
0176            MOVI   V2,0            ;Log that sequencer is not in use
0177            HALT   

; give heartbeat 6 pulse
0178 HB6:   '6  MOVI   V2,1            ;Log that sequencer is in use
0179            DIGLOW [.....110]
0180            MARK   106             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....00.]
0181            MOVI   V2,0            ;Log that sequencer is not in use
0182            HALT   

; give heartbeat 7 pulse
0183 HB7:   '7  MOVI   V2,1            ;Log that sequencer is in use
0184            DIGLOW [.....111]
0185            MARK   107             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....000]
0186            MOVI   V2,0            ;Log that sequencer is not in use
0187            HALT   


; Tell ASL to open file for output (and force marker bits low)
0188 ASLOPEN: 'I MOVI  V2,1            ;Log that sequencer is in use
0189            DIGLOW [.1...000]      ;open file, XDAT bit 6
0190            MOVI   V2,0            ;Log that sequencer is not in use
0191            HALT   

; Tell ASL to close output file (and force marker bits low)
0192 ASLCLOSE: 'i MOVI V2,1            ;Log that sequencer is in use
0193            DIGLOW [.0...000]      ;close file
0194            MOVI   V2,0            ;Log that sequencer is not in use
0195            HALT   

; Tell ASL to start recording to open output file (and force marker bits low)
0196 ASLREC: 'W MOVI   V2,1            ;Log that sequencer is in use
0197            DIGLOW [..1..000]      ;start recording, XDAT bit 5 (7 no worky)
0198            MOVI   V2,0            ;Log that sequencer is not in use
0199            HALT   

; Tell ASL to stop recording; do not close output file (and force marker bits low)
0200 ASLSTOPR: 'w MOVI V2,1            ;Log that sequencer is in use
0201            DIGLOW [..0..000]      ;stop recording, XDAT bit 5 (7 no worky)
0202            MOVI   V2,0            ;Log that sequencer is not in use
0203            HALT