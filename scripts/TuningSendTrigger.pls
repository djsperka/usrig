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
;Send trigger pulse when recording begins
0000            DIGLOW [00001000]      ;Send trigger pulse
0001            DELAY  ms(1)           ;allow pulse to be 1 ms long
0002            DIGLOW [00000000]      ;Turn off pulse, now move to zero DIGOUTs

; zero out all trigger lines, close juicer
0003 ZERO:  '0  MOVI   V2,1            ;Log that sequencer is in use
0004            BLT    V3,1,ZOPENHI    ;Branch, if V3 is 0, go to ZOPENHI
0005            DIGOUT [00000001]      ;Set juicer bit to closed (1 is closed)
0006            JUMP   ZERODONE        ;Jump over ZOPENHI to MOVI
0007 ZOPENHI:   DIGOUT [00000000]      ;Set juicer bit to closed (0 is closed)
0008 ZERODONE:  MOVI   V2,0            ;Log that sequencer is not in use
0009            HALT                   ;End of this sequence section


0010 FIXON: 'F  MOVI   V2,1            ;Log that sequencer is in use
0011            DIGOUT [......1.]      ;Signals the fixation point on
0012            BEQ    V5,1,VWAIT
0013            MOVI   V2,0            ;Log that sequencer is not in use
0014            HALT                   ;End of this sequence section

0015 FIXOFF: 'f MOVI   V2,1            ;Log that sequencer is in use
0016            DIGOUT [......0.]      ;Signals the fixation point off
0017            MOVI   V2,0            ;Log that sequencer is not in use
0018            HALT                   ;End of this sequence section

0019 STIMON: 'S MOVI   V2,1            ;Log that sequencer is in use
0020            DIGOUT [..0..1..]      ;Signals the stimuli on
0021            BEQ    V5,1,VWAIT
0022            MOVI   V2,0            ;Log that sequencer is not in use
0023            HALT                   ;End of this sequence section

0024 STIMOFF: 's MOVI  V2,1            ;Log that sequencer is in use
0025            DIGOUT [.....0..]      ;Signals the stimuli off
0026            MOVI   V2,0            ;Log that sequencer is not in use
0027            HALT                   ;End of this sequence section

0028 FXSTIMON: 'C MOVI V2,1            ;Log that sequencer is in use
0029            DIGOUT [.....11.]      ;Signals the stimulus and fixpt on
0030            BEQ    V5,1,VWAIT
0031            MOVI   V2,0            ;Log that sequencer is not in use
0032            HALT   

0033 STIMADV: 'a MOVI  V2,1            ;Log that sequencer is in use
0034            DIGOUT [....i...]      ;Signals the tuned parameter to advance
;                BEQ    V5,1,VWAIT     ;no branch for triggering, cmdline to fixstim should 
;                     ;omit 'a' from V arg, e.g. "-V 128,FS" , not "-V 128,FSa" or "-V 128"
0035            MOVI   V2,0            ;Log that sequencer is not in use
0036            HALT                   ;End of this sequence section

0037 TOGGHOLE: 'v MOVI V2,1            ;Log that sequencer is in use
0038            DIGOUT [..i.....]      ;Signals the tuned parameter to advance
0039            MOVI   V2,0            ;Log that sequencer is not in use
0040            HALT                   ;End of this sequence section

0041 TOGDONUT: 'u MOVI V2,1            ;Log that sequencer is in use
0042            DIGOUT [.i......]      ;Signals the tuned parameter to advance, this doesn't work
0043            MOVI   V2,0            ;Log that sequencer is not in use
0044            HALT                   ;End of this sequence section

0045 ALTSTIM: 'U MOVI  V2,1            ;Log that sequencer is in use
0046            DIGOUT [..1..0..]      ;Signals the tuned parameter to advance, this doesn't work
0047            MOVI   V2,0            ;Log that sequencer is not in use
0048            HALT                   ;End of this sequence section

0049 QUIT:  'Q  MOVI   V2,1            ;Log that sequencer is in use
0050            DIGOUT [...1....]      ;tells stim we are finished. Program should exit.
0051            MOVI   V2,0            ;Log that sequencer is not in use
0052            HALT                   ;End of this sequence section

0053 CLEAR: 'X  MOVI   V2,1            ;Log that sequencer is in use
0054            DIGOUT [..0..00.]      ;Clears fixation and stim triggers
;                                       DJS - include turning off U trigger.
;                BEQ    V5,1,VWAIT      ; no branch for triggering, cmdline to fixstim should 
;                       ;omit 'X' from V arg, e.g. "-V 128,FS" , not "-V 128,FSX" or "-V 128"
0055            MOVI   V2,0            ;Log that sequencer is not in use
0056            HALT                   ;End of this sequence section

0057 VWAIT:     WAIT   [......11]
0058 TRIGGER: 'V MOVI  V2,1            ;Log that sequencer is in use
0059            DIGOUT [1.......]      ;Trigger to present stim chg.
0060            DELAY  ms(50)
;                DELAY  ms(100)
0061            DIGOUT [0.......]
0062            MOVI   V2,0            ;Log that sequencer is not in use
0063            HALT                   ;End of this sequence section


; Reward
0064 REW:   'R  MOVI   V2,1            ;Log that sequencer is in use
0065            BLT    V3,1,REWHI      ;Branch, if V3 is 0, go to REWHI
0066            DIGOUT [.......1]      ;Assert that juicer is closed
0067            DIGOUT [.......0]      ;Downward pulse delivers juice
0068            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0069            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0070            JUMP   RDONE           ;Jump over REWHI to a HALT
0071 REWHI:     DIGOUT [.......0]      ;Assert that juicer is closed
0072            BLE    V1,0,RDONE      ;Skip if V1 is <= 0
0073            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0074            DIGOUT [.......1]      ;Voltage High delivers juice
0075            DELAY  V1              ;Delay V1 ms, duration of reward
0076            DIGOUT [.......0]      ;Close juicer valve
0077 RDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0078            HALT                   ;End of this sequence section

; Reward, compatible with 'J'uicer command from Farran's rig, just do same thing as 'R'
0079 JCR:   'J  MOVI   V2,1            ;Log that sequencer is in use
0080            BLT    V3,1,JCRHI      ;Branch, if V3 is 0, go to JCRHI
0081            DIGOUT [.......1]      ;Assert that juicer is closed
0082            DIGOUT [.......0]      ;Downward pulse delivers juice
0083            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0084            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0085            JUMP   JDONE           ;Jump over JCRHI to a HALT
0086 JCRHI:     BLE    V1,0,JDONE      ;Skip if V1 is <= 0
0087            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0088            DIGOUT [.......0]      ;Assert that juicer is closed
0089            DIGOUT [.......1]      ;Voltage High delivers juice
0090            DELAY  V1              ;Delay V1 ms, duration of reward
0091            DIGOUT [.......0]      ;Close juicer valve
0092 JDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0093            HALT                   ;End of this sequence section

; Simple optogenetics, just blanketing the stimulus 
0094 OPTOON: 'O MOVI   V2,1            ;Log that sequencer is in use
0095            DAC    0,V4            ;Set DAC0 to the value in V4
0096            MARK   1               ;Mark onset of laser on digital marker channel
0097            MOVI   V2,0            ;Log that sequencer is not in use
0098            HALT                   ;End of this sequence section

0099 OPTOOFF: 'o MOVI  V2,1            ;Log that sequencer is in use
0100            DAC    0,0             ;Set DAC0 to 0
0101            MARK   0               ;Mark offset of laser on digital marker channel
0102            MOVI   V2,0            ;Log that sequencer is not in use
0103            HALT                   ;End of this sequence section

0104 NOOPTO: 'N HALT                   ;Simply reserving this sequence to do nothing

0105 NOOPTOFF: 'n HALT                 ;Simply reserving this sequence to do nothing

; Complicated optogenetics, pulsing
0106 PULSOPTO: 'P MOVI V2,1            ;Log that sequencer is in use
0107            DIGOUT [.....1..]      ;Send stimulus on signal to VSG
0108 PDELAY:    DELAY  V9              ;Wait until first pulse on, subtract 1 tick
0109 PULSEON:   DAC    0,V4            ;Set DAC0 to the value in V4
0110            MARK   1               ;Mark onset of laser on digital marker channel
0111            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0112            DAC    0,0             ;Set DAC0 to 0
0113            MARK   0               ;Mark offset of laser on digital marker channel
0114            DBNZ   V6,PULSEIPI     ;Decrement #pulses, go to IPI if more
0115            JUMP   PULSEXIT        ;Jump to wait/exit from pulse/stim
0116 PULSEIPI:  BLT    V6,0,PULSEXIT   ;Failsafe, if <0 get out before infinite decrement
0117            DELAY  V8              ;Wait through IPI, subtract 4 ticks
0118            JUMP   PULSEON         ;Start next pulse
0119 PULSEXIT:  DELAY  V10             ;Wait until stim should go off, subtract 3 ticks
0120            DIGOUT [.....0..]      ;Signals the stimuli off
0121            MOVI   V2,0            ;Log that sequencer is not in use
0122            HALT                   ;End of this sequence section

; Simpler opto/e-stim, gives one pulse
0123 ONEPING: 'p MOVI  V2,1            ;Log that sequencer is in use
0124            DAC    0,V4            ;Set DAC0 to the value in V4
0125            MARK   1               ;Mark onset of laser on digital marker channel
0126            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0127            DAC    0,0             ;Set DAC0 to 0
0128            MARK   0               ;Mark offset of laser on digital marker channel
0129            MOVI   V2,0            ;Log that sequencer is not in use
0130            HALT                   ;End of this sequence section


; Abort for pulsing optgenetics, cannot use SafeSampleKey to call this
0131 PULSABRT: 'B DAC  0,0             ;Set DAC0 to 0
0132            MARK   0               ;Mark offset of laser on digital marker channel
0133            DIGOUT [.....0..]      ;Signals the stimuli off
0134            MOVI   V2,0            ;Log that sequencer is not in use
0135            HALT                   ;End of this sequence section

; LED commands for fixation LED - these were for Ben, DIGLOWS now for ASL file 
;     LEDON:  'L MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [1.......]      ;Turn on LED - don't know which digout yet
;                JUMP   LDONE           ;Jump over LEDOFF to a HALT
;     LEDOFF: 'M MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [0.......]      ;Turn off LED - don't know which digout yet
;     LDONE:     MOVI   V2,0            ;Log that sequencer is not in use
;                HALT                   ;End of this sequence section


; zero out all DIGLOW lines
0136 ZEROLOW: 'Z MOVI  V2,1            ;Log that sequencer is in use
0137            DIGLOW [00000000]
0138            MOVI   V2,0            ;Log that sequencer is not in use
0139            HALT   

; give heartbeat 1 pulse
0140 HB1:   '1  MOVI   V2,1            ;Log that sequencer is in use
0141            DIGLOW [.....001]
0142            MARK   101             ;Mark heartbeat on digital marker channel
;0130            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0131            DIGLOW [.......0]
0143            MOVI   V2,0            ;Log that sequencer is not in use
0144            HALT   

; give heartbeat 2 pulse
0145 HB2:   '2  MOVI   V2,1            ;Log that sequencer is in use
0146            DIGLOW [.....010]
0147            MARK   102             ;Mark heartbeat on digital marker channel
;0137            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0138            DIGLOW [......0.]
0148            MOVI   V2,0            ;Log that sequencer is not in use
0149            HALT   

; give heartbeat 3 pulse
0150 HB3:   '3  MOVI   V2,1            ;Log that sequencer is in use
0151            DIGLOW [.....011]
0152            MARK   103             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [......00]
0153            MOVI   V2,0            ;Log that sequencer is not in use
0154            HALT   

; give heartbeat 4 pulse
0155 HB4:   '4  MOVI   V2,1            ;Log that sequencer is in use
0156            DIGLOW [.....100]
0157            MARK   104             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0..]
0158            MOVI   V2,0            ;Log that sequencer is not in use
0159            HALT   

; give heartbeat 5 pulse
0160 HB5:   '5  MOVI   V2,1            ;Log that sequencer is in use
0161            DIGLOW [.....101]
0162            MARK   105             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0.0]
0163            MOVI   V2,0            ;Log that sequencer is not in use
0164            HALT   

; give heartbeat 6 pulse
0165 HB6:   '6  MOVI   V2,1            ;Log that sequencer is in use
0166            DIGLOW [.....110]
0167            MARK   106             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....00.]
0168            MOVI   V2,0            ;Log that sequencer is not in use
0169            HALT   

; give heartbeat 7 pulse
0170 HB7:   '7  MOVI   V2,1            ;Log that sequencer is in use
0171            DIGLOW [.....111]
0172            MARK   107             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....000]
0173            MOVI   V2,0            ;Log that sequencer is not in use
0174            HALT   


; Tell ASL to open file for output (and force marker bits low)
0175 ASLOPEN: 'I MOVI  V2,1            ;Log that sequencer is in use
0176            DIGLOW [.1...000]      ;open file, XDAT bit 6
0177            MOVI   V2,0            ;Log that sequencer is not in use
0178            HALT   

; Tell ASL to close output file (and force marker bits low)
0179 ASLCLOSE: 'i MOVI V2,1            ;Log that sequencer is in use
0180            DIGLOW [.0...000]      ;close file
0181            MOVI   V2,0            ;Log that sequencer is not in use
0182            HALT   

; Tell ASL to start recording to open output file (and force marker bits low)
0183 ASLREC: 'W MOVI   V2,1            ;Log that sequencer is in use
0184            DIGLOW [..1..000]      ;start recording, XDAT bit 5 (7 no worky)
0185            MOVI   V2,0            ;Log that sequencer is not in use
0186            HALT   

; Tell ASL to stop recording; do not close output file (and force marker bits low)
0187 ASLSTOPR: 'w MOVI V2,1            ;Log that sequencer is in use
0188            DIGLOW [..0..000]      ;stop recording, XDAT bit 5 (7 no worky)
0189            MOVI   V2,0            ;Log that sequencer is not in use
0190            HALT   


; Timing pulse/DIGMARK for dual 1401 
0191 TPULSE: 'T DIGLOW [...1....]      ;Send timing pulse
0192            MARK   99              ;Mark send of timing pulse on DIGMARK channel
0193            DELAY  ms(1)           ;Leave pulse on for 1 ms
0194            DIGLOW [...0....]      ;Turn off pulse
0195            HALT