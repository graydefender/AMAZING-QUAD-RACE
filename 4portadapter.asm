//********************************************
//          joystick/user port handling
//********************************************

//**** read joystick + 2 port user adapter
*=* "joyread"
JOY_READ:                     
                    lda            $dc01     // read JOY_PORT1
                    and            #$1f
                    sta            [JOY_PORT+$00]
                    lda            $dc00     // read JOY_PORT2
                    and            #$1f
                    sta            [JOY_PORT+$01]
                    lda            $dd01     // cia2 JOY_PORTb bit7 = 1
                    ora            #$80
                    sta            $dd01
                    lda            $dd01     // read JOY_PORT3
                    and            #$1f
                    sta            [JOY_PORT+$02]
                    lda            $dd01     // cia2 JOY_PORTb bit7 = 0
                    and            #$7f
                    sta            $dd01
                    lda            $dd01     // read JOY_PORT4
                    pha                      // attention: fire for JOY_PORT4 on bit5, not 4!
                    and            #$0f
                    sta            [JOY_PORT+$03]
                    pla
                    and            #$20
                    lsr
                    ora            [JOY_PORT+$03]
                    sta            [JOY_PORT+$03]
                    rts
*=* "joyread end"                    