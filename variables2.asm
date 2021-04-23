//*****************************************************
//                 Random Variables
// These were shuffled around to fit into the space
// just under $300
//*****************************************************

*=* "BEGIN Variables 2 at $291"

//*****************************************************
// Display winner displays the game over text
// No Inputs / Outputs
//*****************************************************
Display_Winner:
				inc       gameover				// Set game over flag
				ldy       #0             		// Display player #  wins!
@loop:              lda       WINS,y
				beq       !+
				sta       ScreenRam+$3cc,y
				iny
				bne       @loop   			    
!:                  rts

*=$2a1		"BEGIN $2a1"		
				    .byte      00                  // This is at $02a1 skipped as is bashed by loading process according to @C64Mark
*=* "Cont Variables 2 at $2a2"

//*****************************************************
// Init Sound
// No Inputs / Outputs 
// Y preserved
//*****************************************************
Sound_Init:      
				tya
				pha                
                    ldy        #23                 
!:                  lda        #0                  
                    sta        SND,y                
                    dey
                    bpl !-                    
                    pla
                    tay
                    lda        #15           // Shared code between 
                    sta        SND+24        // The two sound routines
                    lda        #45                 
                    sta        SND+1                                  
                    lda        #17                  
                    sta        SND+4  
                    rts	
//*****************************************************
// Init random generator 
// No Inputs / Outputs
//*****************************************************
Init_Random: //14  bytes
                    lda            #$FF      // maximum frequency value
                    sta            $D40E     // voice 3 frequency low byte
                    sta            $D40F     // voice 3 frequency high byte
                    lda            #$80      // noise SIRENform, gate bit off
                    sta            $D412     // voice 3 control register
                    rts

TIES:               .text     " have tied!!" // 13 bytes
                    .byte     00

Players_Win_X:      .byte     RESET_PL2_X,RESET_PL1_X,RESET_PL4_X,RESET_PL3_X  // Winning positions for
Players_Win_Y:      .byte     RESET_PL2_Y,RESET_PL1_Y,RESET_PL4_Y,RESET_PL3_Y  // all players

ANIMATION_CHRS:   
				.byte     100,111,98,247,Const_WALL,0,0,0,247,98,111,100   // 12 bytes
GRD:                .text     " gray defender 2021" //20 bytes
				.byte     00								  
WINS:               .text     "player #  wins!"     //16 bytes
                    .byte     00    
                                   
*=* "END - Variables 2 Should END at $313"						