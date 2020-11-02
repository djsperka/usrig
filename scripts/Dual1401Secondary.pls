; $Id$
;

                SET    0.010,1,0       ;Get rate & scaling OK


;Send handshake pulse when recording begins
0000            DELAY  ms(50)          ;wait 50 ms to send
0001            DIGOUT [00000001]      ;Send trigger pulse
0002            DELAY  ms(1)           ;allow pulse to be 1 ms long
0003            DIGOUT [00000000]      ;Turn off pulse, now move to zero DIGOUTs
0004            HALT