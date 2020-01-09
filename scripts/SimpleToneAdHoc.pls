                SET    0.010,1,0       ;Get rate & scaling OK
0000            JUMP   NEXT
0001 CEDV:  'N  RATE   1,Hz(10)
0002            DELAY  S(1)-1
0003        'O  RATE   1,0
0004            HALT   
0005 BEGIN: 'S  SZ     1,1             ;set amplitude on DAC1 to 1
0006            RATE   1,Hz(1000)      ;start tone playing at 1 kHz
0007            MARK   1               ;digital marker (test)
0008 LOOP:      DELAY  S(1)-1
0009            JUMP   LOOP
0010 STOP:  'T  RATE   1,0             ;stop tone
0011            MARK   2
0012 NEXT:      NOP