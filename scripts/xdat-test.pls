; $Id$
;

            SET      0.010 1 0     ;Get rate & scaling OK
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
        '0  DIGOUT [00000000]      ;Set juicer bit to closed (0 is closed)
            DIGLOW [00000000]
            HALT                   ;End of this sequence section

        '1  DIGLOW [...00001]
            HALT

        '2  DIGLOW [...00010]
            HALT

        '3  DIGLOW [...00100]
            HALT

        '4  DIGLOW [...01000]
            HALT

        '5  DIGLOW [...10000]
            HALT

        'O  DIGLOW [.1.00000]   ; open file, XDAT bit 6
            HALT

        'o  DIGLOW [.0.00000]   ; close file
            HALT

        'R  DIGLOW [..100000]   ; start recording, XDAT bit 7
            HALT

        'r  DIGLOW [..000000]   ; stop recording, XDAT bit 7
            HALT
