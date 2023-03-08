; Revision 1.1  2011/11/07 jeff
; Added multiple juicer functionality

                SET    1.000,1,0       ;Get rate & scaling OK


; clear all output bits 1-7 (0 is untouched)
0000 E0:    '0  DIGOUT [0000000.]
0001            DELAY  s(0.996)-1
0002            HALT                   ;End of this sequence section


; set bit 1
0003 E1:    '1  DIGOUT [0000001.]
0004            DELAY  s(0.050)-1
0005            DIGOUT [0000000.]
0006            HALT                   ;End of this sequence section

0007 E2:    '2  DIGOUT [0000010.]
0008            DELAY  s(0.050)-1
0009            DIGOUT [0000000.]
0010            HALT                   ;End of this sequence section

0011 E3:    '3  DIGOUT [0000100.]
0012            DELAY  s(0.050)-1
0013            DIGOUT [0000000.]
0014            HALT                   ;End of this sequence section

0015 E4:    '4  DIGOUT [0001000.]
0016            DELAY  s(0.050)-1
0017            DIGOUT [0000000.]
0018            HALT                   ;End of this sequence section

0019 E5:    '5  DIGOUT [0010000.]
0020            DELAY  s(0.050)-1
0021            DIGOUT [0000000.]
0022            HALT                   ;End of this sequence section

0023 E6:    '6  DIGOUT [0100000.]
0024            DELAY  s(0.050)-1
0025            DIGOUT [0000000.]
0026            HALT                   ;End of this sequence section

0027 E7:    '7  DIGOUT [1000000.]
0028            DELAY  s(0.050)-1
0029            DIGOUT [0000000.]
0030            HALT                   ;End of this sequence section

0031 JCR:   'J  BLT    V3,1,JCRHI      ;Branch, if V3 is 0, go to JCRHI
0032            DIGOUT [.......1]      ;Assert that juicer is closed
0033            DIGOUT [.......0]      ;Downward pulse delivers juice
0034            DELAY  s(0.005)-1      ;Delay for 5 ms for adequate pulse width
0035            DIGOUT [.......1]      ;End downward pulse, juicer will close on its own
0036            JUMP   JDONE           ;Jump over JCRHI to a HALT
0037 JCRHI:     BLE    V1,0,JDONE      ;Skip if V1 is <= 0
0038            MULI   V1,ms(1)        ;convert V1 from ms to clock ticks
0039            DIGOUT [.......0]      ;Assert that juicer is closed
0040            DIGOUT [.......1]      ;Voltage High delivers juice
0041            DELAY  V1              ;Delay V1 ms, duration of reward
0042            DIGOUT [.......0]      ;Close juicer valve
0043 JDONE:     HALT                   ;End of this sequence section

0044 EQ:    'q  DIGOUT [1111000.]
0045            DELAY  10
0046            HALT   

0047 EZ:    'z  DIGOUT [1111111.]
0048            HALT                   ;End of this sequence section