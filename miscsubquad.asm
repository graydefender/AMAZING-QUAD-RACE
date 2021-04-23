//**********************************
// Screen quadrants
//   Quad1   Quad2
//
//   Quad3   Quad4
//
// Placed here to fill in 143 bytes
// at $200
// Inputs : Acc = Color to switch to
// Outputs: None
//**********************************
*=* "Miscsubquad start"
Quad4:              sta       CH_Color      //35 bytes
					clc
					txa
					adc       #12            
					tax
					clc
					tya
					adc       #20            
					tay
*=* "OPTQUADSUB"
Opt_QuadSub:
					cpx       #23            // keep title .text same color
					bcs       !+             // Don't re-color bottom 2 rows

				    lda       #LDY_ABS		 // Change pokecolsxy to not store character on screen
				    sta       screen         // by changing sta $beef,y to a lda $beef,y					
					jsr 	  pokeColsxy	
				    lda       #STY_ABS		 // Change back to sta $beef,y 
				    sta       screen
!:      	        ldx       TEMPX
					ldy       TEMPY          
					rts
						
UpdateFrameCounter:  // 20 bytes
!:                  lda       #240           // Scanline -> A
					cmp       RASTER         // Compare A to current raster line
					bne       !-          
					inc       FrameCounter   
					lda       FrameCounter   
					cmp       #MAX_FRAMES                
					bne       !+
					lda       #0             
					sta       FrameCounter   
!:                  rts
//*********************************************
// Delay used in flashing routine and sounds
// Inputs :  X register = duration of delay
// Outputs: none
//*********************************************
delay:						// 21 bytes
					txa
					pha
dly_value:  		ldy       #10            
!:                  ldx       #0
!:                  dex
					bne       !-
					jsr       UpdateFrameCounter        // Continue corner animations during winning anim.
					jsr       Update_Corner_Animations
					dey
					bne       !--         
					pla
					tax
					rts
//************************************
// Sounds use: x,y | Y is preserved
// Inputs : none
// Outputs: none 
//************************************
Sounds: {			// 35 bytes     
	
Sound_Winner:										// Plays when a winner is declared
					jsr        Sound_Init					  
                    lda        #143
                    sta        SND+5               
                    ldx 	   #0
!:                  lda 	   music_notes,x
                    beq 	   !+
                    sta 	   SND+1
                    jsr 	   delay
                    inx			
                    bne 	   !-
!:			        lda 	   #77
                    sta 	   SND+1
Sound_Opt:          lda        #43                 
                    sta        SND+5 
                    rts	
}

//***************************************************************
// Random variables for program to fit in perfectly under $400
//***************************************************************

RESET_Players_X:    .byte     RESET_PL1_X,RESET_PL2_X,RESET_PL3_X,RESET_PL4_X   
RESET_Players_Y:    .byte     RESET_PL1_Y,RESET_PL2_Y,RESET_PL3_Y,RESET_PL4_Y 

*=* "$277 START cant use"              // $278 was being overwritten when using vice 2.4 at least and $277 is kbd buffer
					.fill     23,$00   // Cant use, I believe $28b, and $28c being using by IRQ perhaps $28d?
*=* "Miscsubquad END should be $28e"