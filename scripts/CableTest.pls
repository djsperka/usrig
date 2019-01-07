; Revision 1.1  2011/11/07 jeff
; Added multiple juicer functionality

                SET      1.000 1 0     ;Get rate & scaling OK


; clear all output bits 1-7 (0 is untouched)
0000 E0:     '0 DIGOUT [0000000.]
0001            DELAY  s(0.996)-1
0002            HALT                   ;End of this sequence section


; set bit 1
0006 E1:     '1 DIGOUT [0000001.]
0007            HALT                   ;End of this sequence section

0008 E2:     '2 DIGOUT [0000010.]
0009            HALT                   ;End of this sequence section

0010 E3:     '3 DIGOUT [0000100.]
0012            HALT                   ;End of this sequence section

0013 E4:     '4 DIGOUT [0001000.]
0015            HALT                   ;End of this sequence section

0016 E5:     '5 DIGOUT [0010000.]
0018            HALT                   ;End of this sequence section

0019 E6:     '6 DIGOUT [0100000.]
0021            HALT                   ;End of this sequence section

0022 E7:     '7 DIGOUT [1000000.]
0024            HALT                   ;End of this sequence section

0025 JCR:    'J BLT    V3,1,JCRHI      ;Branch, if V3 is 0, go to JCRHI
0026            DIGOUT [.......1]      ;Assert that juicer is closed
0027            DIGOUT [.......0]      ;Downward pulse delivers juice
0028            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0029            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0030            JUMP   JDONE           ;Jump over JCRHI to a HALT
0031 JCRHI:     BLE    V1,0,JDONE      ;Skip if V1 is <= 0
0032            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0033            DIGOUT [.......0]      ;Assert that juicer is closed
0034            DIGOUT [.......1]      ;Voltage High delivers juice
0035            DELAY  V1              ;Delay V1 ms, duration of reward
0036            DIGOUT [.......0]      ;Close juicer valve
0037 JDONE:     HALT                   ;End of this sequence section

0038 EQ:     'q DIGOUT [1111000.]
0039            DELAY  10
0040            HALT   

0041 EZ:     'z DIGOUT [1111111.]
0042            HALT                   ;End of this sequence section

