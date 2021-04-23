//*****************************************************
//** Initialize all Important variables
//*****************************************************
INIT_ALL_VARIABLES: {

//***************************************************
// Initialize all Zero Page memory in this loop
// No Inputs/Outputs
//***************************************************
*=* "INIT_ALL_VARIABLES"
					jsr 	  Init_Random                    // Need to reinit due to sound routine breaking random
                    ldy 	  #[ZP_END-ZP_BEGIN-1]           // Init all zeropage variables to zero     
                    lda 	  #0
					sta       $d020          
!:                  sta 	  ZP_BEGIN,y
                    dey                    
                    bpl !-
//***************************************************
					lda       #Const_MAZE_WIDTH
					sta       MAZE_WIDTH     
					lda       #Const_MAZE_HEIGHT
					sta       MAZE_HEIGHT  
					ldy       #Ctr_RESET_TTL_lo
					sty       CountDown  
					ldy       #Ctr_RESET_TTL_hi   // 4 is assumed	for next save				
					sty       CountDown+1
					sty       ColorSwapIndex      // 4 stored
 					ldy       #2
 					sty       RND_VALUE           // 2 stored
					sty       x              
					sty       y              
					ldy       #0					
@topofloop:         lda       #cyan               // Clear the screen
					sta       ColorRam,y          // Set char color
					sta       [ColorRam+250],y 
					sta       [ColorRam+500],y 
					sta       [ColorRam+750],y 
					lda       #Const_Space           
					sta       ScreenRam,y    
					sta       [ScreenRam+250],y
					sta       [ScreenRam+500],y
					sta       [ScreenRam+750],y
					iny
					cpy       #250         
					bne       @topofloop
			    
					ldy       #3                 // Reset all players x,y
@toploop:           clc
					tya
					adc       #Player1_CH        // Reverse char of $32 or 1        
					sta       Player_Char,y  
					lda       RESET_Players_X,y
					sta       Players_X,y    
					lda       RESET_Players_Y,y
					sta       Players_Y,y    
					dey
					bpl       @toploop			
			     	rts
}

//***************************************************
// Saves a visit at x,y in screen memory
// Inputs : X,Y
// Outputs: none
//***************************************************
Opt_Poke_Visit:     // 8 bytes
					jsr peekxy
                    ora            #MAZE_VISIT_BIT
                    sta            ($fb),y   // Store result in screen memory
                    rts

pokeColsxy:         //31 bytes
                    lda       scr_off_l,x    // Load scr low .byte into $fb
                    sta       screen+1       
                    sta       colpos+1       
                    clc
                    lda       scr_off_h,x    // Load scr high .byte into $fc
                    sta       screen+2       
                    adc       #[>ColorRam]-4 // Make it $d4
                    sta       colpos+2       
                    lda       Char: #$00
screen:             sta       $fff,y         // Store result in screen memory
                    lda       CH_Color: #$FF // at pos x,y
colpos:             sta       $beef,y        // sel mod     
                    rts
// *********************************************************
// This function, for the vertical moving player will
// check for spaces to the left or right hand side 
// of current player and stop the auto movement at the gap
// Inputs : X,Y
// Outputs: none
// *********************************************************                    
PokeWall_Sub:     // 18 bytes
                    lda            scr_off_l,x // Load scr low byte into $fd
                    sta            $fd
                    lda            scr_off_h,x // Load scr high byte into $fd
                    sta            $fe
                    lda            ($fd),y
                    and            #MAZE_VISIT_BIT
                    ora            #Const_WALL
                    sta            ($fd),y   // Store result in screen memory
                    rts     
*=* "END MISCSUBS Should be $3ff"				
