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




; zero out all DIGLOW lines
0123 ZEROLOW: 'Z MOVI  V2,1            ;Log that sequencer is in use
0124            DIGLOW [00000000]
0125            MOVI   V2,0            ;Log that sequencer is not in use
0126            HALT   

; SET DIGLOW BIT 0X8 
0157    'A  MOVI   V2,1            ;Log that sequencer is in use
0158        DIGLOW [...01...]
0160            MOVI   V2,0            ;Log that sequencer is not in use
0161            HALT   

; PULSE DIGLOW BIT 0X10 
0157    'B  MOVI   V2,1            ;Log that sequencer is in use
0158        DIGLOW [...10...]
0160            MOVI   V2,0            ;Log that sequencer is not in use
0161            HALT   
