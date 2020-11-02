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
0020            DIGOUT [.....1..]      ;Signals the stimuli on
0021            BEQ    V5,1,VWAIT
0022            MOVI   V2,0            ;Log that sequencer is not in use
0023            HALT                   ;End of this sequence section

0024 STIMOFF: 's MOVI  V2,1            ;Log that sequencer is in use
0025            DIGOUT [.....0..]      ;Signals the stimuli off
0026            MOVI   V2,0            ;Log that sequencer is not in use
0027            HALT                   ;End of this sequence section

0028 STIMADV: 'a MOVI  V2,1            ;Log that sequencer is in use
0029            DIGOUT [....i...]      ;Signals the tuned parameter to advance
;                BEQ    V5,1,VWAIT     ;no branch for triggering, cmdline to fixstim should 
;                     ;omit 'a' from V arg, e.g. "-V 128,FS" , not "-V 128,FSa" or "-V 128"
0030            MOVI   V2,0            ;Log that sequencer is not in use
0031            HALT                   ;End of this sequence section

0032 TOGGHOLE: 'v MOVI V2,1            ;Log that sequencer is in use
0033            DIGOUT [..i.....]      ;Signals the tuned parameter to advance
0034            MOVI   V2,0            ;Log that sequencer is not in use
0035            HALT                   ;End of this sequence section

0036 TOGDONUT: 'u MOVI V2,1            ;Log that sequencer is in use
0037            DIGOUT [.i......]      ;Signals the tuned parameter to advance, this doesn't work
0038            MOVI   V2,0            ;Log that sequencer is not in use
0039            HALT                   ;End of this sequence section

0040 QUIT:  'Q  MOVI   V2,1            ;Log that sequencer is in use
0041            DIGOUT [...1....]      ;tells stim we are finished. Program should exit.
0042            MOVI   V2,0            ;Log that sequencer is not in use
0043            HALT                   ;End of this sequence section

0044 CLEAR: 'X  MOVI   V2,1            ;Log that sequencer is in use
0045            DIGOUT [.....00.]      ;Clears fixation and stim triggers
;                BEQ    V5,1,VWAIT      ; no branch for triggering, cmdline to fixstim should 
;                       ;omit 'X' from V arg, e.g. "-V 128,FS" , not "-V 128,FSX" or "-V 128"
0046            MOVI   V2,0            ;Log that sequencer is not in use
0047            HALT                   ;End of this sequence section

0048 VWAIT:     WAIT   [......11]
0049 TRIGGER: 'V MOVI  V2,1            ;Log that sequencer is in use
0050            DIGOUT [1.......]      ;Trigger to present stim chg.
0051            DELAY  ms(50)
;                DELAY  ms(100)
0052            DIGOUT [0.......]
0053            MOVI   V2,0            ;Log that sequencer is not in use
0054            HALT                   ;End of this sequence section


; Reward
0055 REW:   'R  MOVI   V2,1            ;Log that sequencer is in use
0056            BLT    V3,1,REWHI      ;Branch, if V3 is 0, go to REWHI
0057            DIGOUT [.......1]      ;Assert that juicer is closed
0058            DIGOUT [.......0]      ;Downward pulse delivers juice
0059            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0060            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0061            JUMP   RDONE           ;Jump over REWHI to a HALT
0062 REWHI:     BLE    V1,0,RDONE      ;Skip if V1 is <= 0
0063            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0064            DIGOUT [.......0]      ;Assert that juicer is closed
0065            DIGOUT [.......1]      ;Voltage High delivers juice
0066            DELAY  V1              ;Delay V1 ms, duration of reward
0067            DIGOUT [.......0]      ;Close juicer valve
0068 RDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0069            HALT                   ;End of this sequence section

; Reward, compatible with 'J'uicer command from Farran's rig, just do same thing as 'R'
0070 JCR:   'J  MOVI   V2,1            ;Log that sequencer is in use
0071            BLT    V3,1,JCRHI      ;Branch, if V3 is 0, go to JCRHI
0072            DIGOUT [.......1]      ;Assert that juicer is closed
0073            DIGOUT [.......0]      ;Downward pulse delivers juice
0074            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0075            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0076            JUMP   JDONE           ;Jump over JCRHI to a HALT
0077 JCRHI:     BLE    V1,0,JDONE      ;Skip if V1 is <= 0
0078            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0079            DIGOUT [.......0]      ;Assert that juicer is closed
0080            DIGOUT [.......1]      ;Voltage High delivers juice
0081            DELAY  V1              ;Delay V1 ms, duration of reward
0082            DIGOUT [.......0]      ;Close juicer valve
0083 JDONE:     MOVI   V2,0            ;Log that sequencer is not in use
0084            HALT                   ;End of this sequence section

; Simple optogenetics, just blanketing the stimulus 
0085 OPTOON: 'O MOVI   V2,1            ;Log that sequencer is in use
0086            DAC    0,V4            ;Set DAC0 to the value in V4
0087            MARK   1               ;Mark onset of laser on digital marker channel
0088            MOVI   V2,0            ;Log that sequencer is not in use
0089            HALT                   ;End of this sequence section

0090 OPTOOFF: 'o MOVI  V2,1            ;Log that sequencer is in use
0091            DAC    0,0             ;Set DAC0 to 0
0092            MARK   0               ;Mark offset of laser on digital marker channel
0093            MOVI   V2,0            ;Log that sequencer is not in use
0094            HALT                   ;End of this sequence section

0095 NOOPTO: 'N HALT                   ;Simply reserving this sequence to do nothing

0096 NOOPTOFF: 'n HALT                 ;Simply reserving this sequence to do nothing

; Complicated optogenetics, pulsing
0097 PULSOPTO: 'P MOVI V2,1            ;Log that sequencer is in use
0098            DIGOUT [.....1..]      ;Send stimulus on signal to VSG
0099 PDELAY:    DELAY  V9              ;Wait until first pulse on, subtract 1 tick
0100 PULSEON:   DAC    0,V4            ;Set DAC0 to the value in V4
0101            MARK   1               ;Mark onset of laser on digital marker channel
0102            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0103            DAC    0,0             ;Set DAC0 to 0
0104            MARK   0               ;Mark offset of laser on digital marker channel
0105            DBNZ   V6,PULSEIPI     ;Decrement #pulses, go to IPI if more
0106            JUMP   PULSEXIT        ;Jump to wait/exit from pulse/stim
0107 PULSEIPI:  DELAY  V8              ;Wait through IPI, subtract 3 ticks
0108            JUMP   PULSEON         ;Start next pulse
0109 PULSEXIT:  DELAY  V10             ;Wait until stim should go off, subtract 3 ticks
0110            DIGOUT [.....0..]      ;Signals the stimuli off
0111            MOVI   V2,0            ;Log that sequencer is not in use
0112            HALT                   ;End of this sequence section

; Simpler opto/e-stim, gives one pulse
0113 ONEPING: 'p MOVI  V2,1            ;Log that sequencer is in use
0114            DAC    0,V4            ;Set DAC0 to the value in V4
0115            MARK   1               ;Mark onset of laser on digital marker channel
0116            DELAY  V7              ;Wait until pulse off time, subtract 2 ticks
0117            DAC    0,0             ;Set DAC0 to 0
0118            MARK   0               ;Mark offset of laser on digital marker channel
0119            MOVI   V2,0            ;Log that sequencer is not in use
0120            HALT                   ;End of this sequence section


; Abort for pulsing optgenetics, cannot use SafeSampleKey to call this
0121 PULSABRT: 'B DAC  0,0             ;Set DAC0 to 0
0122            MARK   0               ;Mark offset of laser on digital marker channel
0123            DIGOUT [.....0..]      ;Signals the stimuli off
0124            MOVI   V2,0            ;Log that sequencer is not in use
0125            HALT                   ;End of this sequence section

; LED commands for fixation LED - these were for Ben, DIGLOWS now for ASL file 
;     LEDON:  'L MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [1.......]      ;Turn on LED - don't know which digout yet
;                JUMP   LDONE           ;Jump over LEDOFF to a HALT
;     LEDOFF: 'M MOVI   V2,1            ;Log that sequencer is in use
;                DIGLOW [0.......]      ;Turn off LED - don't know which digout yet
;     LDONE:     MOVI   V2,0            ;Log that sequencer is not in use
;                HALT                   ;End of this sequence section


; zero out all DIGLOW lines
0126 ZEROLOW: 'Z MOVI  V2,1            ;Log that sequencer is in use
0127            DIGLOW [00000000]
0128            MOVI   V2,0            ;Log that sequencer is not in use
0129            HALT   

; give heartbeat 1 pulse
0130 HB1:   '1  MOVI   V2,1            ;Log that sequencer is in use
0131            DIGLOW [.....001]
0132            MARK   101             ;Mark heartbeat on digital marker channel
;0130            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0131            DIGLOW [.......0]
0133            MOVI   V2,0            ;Log that sequencer is not in use
0134            HALT   

; give heartbeat 2 pulse
0135 HB2:   '2  MOVI   V2,1            ;Log that sequencer is in use
0136            DIGLOW [.....010]
0137            MARK   102             ;Mark heartbeat on digital marker channel
;0137            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0138            DIGLOW [......0.]
0138            MOVI   V2,0            ;Log that sequencer is not in use
0139            HALT   

; give heartbeat 3 pulse
0140 HB3:   '3  MOVI   V2,1            ;Log that sequencer is in use
0141            DIGLOW [.....011]
0142            MARK   103             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [......00]
0143            MOVI   V2,0            ;Log that sequencer is not in use
0144            HALT   

; give heartbeat 4 pulse
0145 HB4:   '4  MOVI   V2,1            ;Log that sequencer is in use
0146            DIGLOW [.....100]
0147            MARK   104             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0..]
0148            MOVI   V2,0            ;Log that sequencer is not in use
0149            HALT   

; give heartbeat 5 pulse
0150 HB5:   '5  MOVI   V2,1            ;Log that sequencer is in use
0151            DIGLOW [.....101]
0152            MARK   105             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....0.0]
0153            MOVI   V2,0            ;Log that sequencer is not in use
0154            HALT   

; give heartbeat 6 pulse
0155 HB6:   '6  MOVI   V2,1            ;Log that sequencer is in use
0156            DIGLOW [.....110]
0157            MARK   106             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....00.]
0158            MOVI   V2,0            ;Log that sequencer is not in use
0159            HALT   

; give heartbeat 7 pulse
0160 HB7:   '7  MOVI   V2,1            ;Log that sequencer is in use
0161            DIGLOW [.....111]
0162            MARK   107             ;Mark heartbeat on digital marker channel
;0144            DELAY  s(0.010)-2      ;Delay for 10 ms for adequate pulse width
;0145            DIGLOW [.....000]
0163            MOVI   V2,0            ;Log that sequencer is not in use
0164            HALT   


; Tell ASL to open file for output (and force marker bits low)
0165 ASLOPEN: 'I MOVI  V2,1            ;Log that sequencer is in use
0166            DIGLOW [.1...000]      ;open file, XDAT bit 6
0167            MOVI   V2,0            ;Log that sequencer is not in use
0168            HALT   

; Tell ASL to close output file (and force marker bits low)
0169 ASLCLOSE: 'i MOVI V2,1            ;Log that sequencer is in use
0170            DIGLOW [.0...000]      ;close file
0171            MOVI   V2,0            ;Log that sequencer is not in use
0172            HALT   

; Tell ASL to start recording to open output file (and force marker bits low)
0173 ASLREC: 'W MOVI   V2,1            ;Log that sequencer is in use
0174            DIGLOW [..1..000]      ;start recording, XDAT bit 5 (7 no worky)
0175            MOVI   V2,0            ;Log that sequencer is not in use
0176            HALT   

; Tell ASL to stop recording; do not close output file (and force marker bits low)
0177 ASLSTOPR: 'w MOVI V2,1            ;Log that sequencer is in use
0178            DIGLOW [..0..000]      ;stop recording, XDAT bit 5 (7 no worky)
0179            MOVI   V2,0            ;Log that sequencer is not in use
0180            HALT


; Timing pulse/DIGMARK for dual 1401 
0181 TPULSE: 'T DIGLOW [...1....]     ;Send timing pulse
0182            MARK 99               ;Mark send of timing pulse on DIGMARK channel
0183            DELAY  ms(1)          ;Leave pulse on for 1 ms
0184            DIGLOW [...0....]     ;Turn off pulse
0185            HALT