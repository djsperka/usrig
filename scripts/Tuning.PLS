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

0025 STIMADV: 'a MOVI  V2,1            ;Log that sequencer is in use
0026            DIGOUT [....i...]      ;Signals the tuned parameter to advance
;                BEQ    V5,1,VWAIT     ;no branch for triggering, cmdline to fixstim should 
;                     ;omit 'a' from V arg, e.g. "-V 128,FS" , not "-V 128,FSa" or "-V 128"
0027            MOVI   V2,0            ;Log that sequencer is not in use
0028            HALT                   ;End of this sequence section

0029 TOGGHOLE: 'v MOVI V2,1            ;Log that sequencer is in use
0030            DIGOUT [..i.....]      ;Signals the tuned parameter to advance
0031            MOVI   V2,0            ;Log that sequencer is not in use
0032            HALT                   ;End of this sequence section

0033 TOGDONUT: 'u MOVI V2,1            ;Log that sequencer is in use
0034            DIGOUT [.i......]      ;Signals the tuned parameter to advance, this doesn't work
0035            MOVI   V2,0            ;Log that sequencer is not in use
0036            HALT                   ;End of this sequence section

0037 QUIT:  'Q  MOVI   V2,1            ;Log that sequencer is in use
0038            DIGOUT [...1....]      ;tells stim we are finished. Program should exit.
0039            MOVI   V2,0            ;Log that sequencer is not in use
0040            HALT                   ;End of this sequence section

0041 CLEAR: 'X  MOVI   V2,1            ;Log that sequencer is in use
0042            DIGOUT [.....00.]      ;Clears fixation and stim triggers
;                BEQ    V5,1,VWAIT      ; no branch for triggering, cmdline to fixstim should 
;                       ;omit 'X' from V arg, e.g. "-V 128,FS" , not "-V 128,FSX" or "-V 128"
0043            MOVI   V2,0            ;Log that sequencer is not in use
0044            HALT                   ;End of this sequence section

0045 VWAIT:     WAIT   [......11]
0046 TRIGGER: 'V MOVI  V2,1            ;Log that sequencer is in use
0047            DIGOUT [1.......]      ;Trigger to present stim chg.
0048            DELAY  ms(50)
;                DELAY  ms(100)
0049            DIGOUT [0.......]
0050            MOVI   V2,0            ;Log that sequencer is not in use
0051            HALT                   ;End of this sequence section


; Reward
0052 REW:   'R  MOVI   V2,1            ;Log that sequencer is in use
0053            BLT    V3,1,REWHI      ;Branch, if V3 is 0, go to REWHI
0054            DIGOUT [.......1]      ;Assert that juicer is closed
0055            DIGOUT [.......0]      ;Downward pulse delivers juice
0056            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0057            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0058            JUMP   RDONE           ;Jump over REWHI to a HALT
0059 REWHI:     BLE    V1,0,RDONE      ;Skip if V1 is <= 0
0060            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0061            DIGOUT [.......0]      ;Assert that juicer is closed
0062            DIGOUT [.......1]      ;Voltage High delivers juice
0063            DELAY  V1              ;Delay V1 ms, duration of reward
0064            DIGOUT [.......0]      ;Close juicer valve
0065 RDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0066            HALT                   ;End of this sequence section

; Reward, compatible with 'J'uicer command from Farran's rig, just do same thing as 'R'
0067 JCR:   'J  MOVI   V2,1            ;Log that sequencer is in use
0068            BLT    V3,1,JCRHI      ;Branch, if V3 is 0, go to JCRHI
0069            DIGOUT [.......1]      ;Assert that juicer is closed
0070            DIGOUT [.......0]      ;Downward pulse delivers juice
0071            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0072            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0073            JUMP   JDONE           ;Jump over JCRHI to a HALT
0074 JCRHI:     BLE    V1,0,JDONE      ;Skip if V1 is <= 0
0075            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0076            DIGOUT [.......0]      ;Assert that juicer is closed
0077            DIGOUT [.......1]      ;Voltage High delivers juice
0078            DELAY  V1              ;Delay V1 ms, duration of reward
0079            DIGOUT [.......0]      ;Close juicer valve
0080 JDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0081            HALT                   ;End of this sequence section

; Simple optogenetics, just blanketing the stimulus 
0082 OPTOON: 'O MOVI   V2,1            ;Log that sequencer is in use
0083            DAC    0,V4            ;Set DAC0 to the value in V4
0084            MARK   1               ;Mark onset of laser on digital marker channel
0085            MOVI   V2,0            ;Log that sequencer is not in use
0086            HALT                   ;End of this sequence section

0087 OPTOOFF: 'o MOVI  V2,1            ;Log that sequencer is in use
0088            DAC    0,0             ;Set DAC0 to 0
0089            MARK   0               ;Mark offset of laser on digital marker channel
0090            MOVI   V2,0            ;Log that sequencer is not in use
0091            HALT                   ;End of this sequence section

0092 NOOPTO: 'N HALT                   ;Simply reserving this sequence to do nothing

0093 NOOPTOFF: 'n HALT                 ;Simply reserving this sequence to do nothing

; Complicated optogenetics, pulsing
0094 PULSOPTO: 'P MOVI V2,1            ;Log that sequencer is in use
0095            DIGOUT [.....1..]      ;Send stimulus on signal to VSG
0096 PDELAY:    DELAY  V9              ;Wait until first pulse on, subtract 1 tick
0097 PULSEON:   DAC    0,V4            ;Set DAC0 to the value in V4
0098            MARK   1               ;Mark onset of laser on digital marker channel
0099            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0100            DAC    0,0             ;Set DAC0 to 0
0101            MARK   0               ;Mark offset of laser on digital marker channel
0102            DBNZ   V6,PULSEIPI     ;Decrement #pulses, go to IPI if more
0103            JUMP   PULSEXIT        ;Jump to wait/exit from pulse/stim
0104 PULSEIPI:  DELAY  V8              ;Wait through IPI, subtract 3 ticks
0105            JUMP   PULSEON         ;Start next pulse
0106 PULSEXIT:  DELAY  V10             ;Wait until stim should go off, subtract 3 ticks
0107            DIGOUT [.....0..]      ;Signals the stimuli off
0108            MOVI   V2,0            ;Log that sequencer is not in use
0109            HALT                   ;End of this sequence section

; Simpler opto/e-stim, gives one pulse
0110 ONEPING: 'p MOVI  V2,1            ;Log that sequencer is in use
0111            DAC    0,V4            ;Set DAC0 to the value in V4
0112            MARK   1               ;Mark onset of laser on digital marker channel
0113            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0114            DAC    0,0             ;Set DAC0 to 0
0115            MARK   0               ;Mark offset of laser on digital marker channel
0116            MOVI   V2,0            ;Log that sequencer is not in use
0117            HALT                   ;End of this sequence section


; Abort for pulsing optgenetics, cannot use SafeSampleKey to call this
0118 PULSABRT: 'B DAC  0,0             ;Set DAC0 to 0
0119            MARK   0               ;Mark offset of laser on digital marker channel
0120            DIGOUT [.....0..]      ;Signals the stimuli off
0121            MOVI   V2,0            ;Log that sequencer is not in use
0122            HALT                   ;End of this sequence section

; LED commands for fixation LED - these were for Ben, DIGLOWS now for ASL file 
;     LEDON:  'L MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [1.......]      ;Turn on LED - don't know which digout yet
;                JUMP   LDONE           ;Jump over LEDOFF to a HALT
;     LEDOFF: 'M MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [0.......]      ;Turn off LED - don't know which digout yet
;     LDONE:     MOVI   V2,0            ;Log that sequencer is not in use
;                HALT                   ;End of this sequence section


; zero out all DIGLOW lines
0123 ZEROLOW: 'Z MOVI  V2,1            ;Log that sequencer is in use
0124            DIGLOW [00000000]
0125            MOVI   V2,0            ;Log that sequencer is not in use
0126            HALT   

; give heartbeat 1 pulse
0127 HB1:   '1  MOVI   V2,1            ;Log that sequencer is in use
0128            DIGLOW [.......1]
0129            MARK   101             ;Mark heartbeat on digital marker channel
;0130            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0131            DIGLOW [.......0]
0130            MOVI   V2,0            ;Log that sequencer is not in use
0131            HALT   

; give heartbeat 2 pulse
0132 HB2:   '2  MOVI   V2,1            ;Log that sequencer is in use
0133            DIGLOW [......1.]
0134            MARK   102             ;Mark heartbeat on digital marker channel
;0137            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0138            DIGLOW [......0.]
0135            MOVI   V2,0            ;Log that sequencer is not in use
0136            HALT   

; give heartbeat 3 pulse
0137 HB3:   '3  MOVI   V2,1            ;Log that sequencer is in use
0138            DIGLOW [......11]
0139            MARK   103             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [......00]
0140            MOVI   V2,0            ;Log that sequencer is not in use
0141            HALT   

; give heartbeat 4 pulse
0142 HB4:   '4  MOVI   V2,1            ;Log that sequencer is in use
0143            DIGLOW [.....1..]
0144            MARK   104             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0..]
0145            MOVI   V2,0            ;Log that sequencer is not in use
0146            HALT   

; give heartbeat 5 pulse
0147 HB5:   '5  MOVI   V2,1            ;Log that sequencer is in use
0148            DIGLOW [.....1.1]
0149            MARK   105             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0.0]
0150            MOVI   V2,0            ;Log that sequencer is not in use
0151            HALT   

; give heartbeat 6 pulse
0152 HB6:   '6  MOVI   V2,1            ;Log that sequencer is in use
0153            DIGLOW [.....11.]
0154            MARK   106             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....00.]
0155            MOVI   V2,0            ;Log that sequencer is not in use
0156            HALT   

; give heartbeat 7 pulse
0157 HB7:   '7  MOVI   V2,1            ;Log that sequencer is in use
0158            DIGLOW [.....111]
0159            MARK   107             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....000]
0160            MOVI   V2,0            ;Log that sequencer is not in use
0161            HALT   


; Tell ASL to open file for output (and force marker bits low)
0162 ASLOPEN: 'I MOVI  V2,1            ;Log that sequencer is in use
0163            DIGLOW [.1...000]      ;open file, XDAT bit 6
0164            MOVI   V2,0            ;Log that sequencer is not in use
0165            HALT   

; Tell ASL to close output file (and force marker bits low)
0166 ASLCLOSE: 'i MOVI V2,1            ;Log that sequencer is in use
0167            DIGLOW [.0...000]      ;close file
0168            MOVI   V2,0            ;Log that sequencer is not in use
0169            HALT   

; Tell ASL to start recording to open output file (and force marker bits low)
0170 ASLREC: 'W MOVI   V2,1            ;Log that sequencer is in use
0171            DIGLOW [..1..000]      ;start recording, XDAT bit 5 (7 no worky)
0172            MOVI   V2,0            ;Log that sequencer is not in use
0173            HALT   

; Tell ASL to stop recording; do not close output file (and force marker bits low)
0174 ASLSTOPR: 'w MOVI V2,1            ;Log that sequencer is in use
0175            DIGLOW [..0..000]      ;stop recording, XDAT bit 5 (7 no worky)
0176            MOVI   V2,0            ;Log that sequencer is not in use
0177            HALT