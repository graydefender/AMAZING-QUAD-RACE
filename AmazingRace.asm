#import              "Constants_ZP.asm"
//BasicUpstart2(Entry)
//*******************************************
//*           A Mazing Race
//*
//* 12/24/2020 Gray Defender
//* 01/08/2021 Finis
//*******************************************

// //Autostarting PRG code under $1000
// // 3767 bytes free for code
// // 254 zero page bytes free for variables
// // 18 bytes at $1ed for variables
// * = $120
// Entry:
//     ldx #$1f 
//     txs    //Push stack down to $100-$11f
//     //Start your code HERE (205 bytes up to $1ec)
//     inc $d020
//     jmp *-3    
// * = $1ed
//     //This area can be used for runtime vars
//     //Once prg is loaded (1ed-1ff = 18 bytes)
//     //But is bashed by the loading process
// * = $1f8  //Override return from load vector on stack         
//     .byte <[Entry-1], >[Entry-1]
// * = $200
//     //143 free bytes here
//     .fill $8f, 0
// *=$028f
//     .byte $48,$eb //Prevent keyboard jam
//     //131 free bytes here
//     .fill $83, 0 
// * = $314 //IRQ, BRK and NMI Vectors
//     .byte $31, $ea, $66, $fe, $47,$fe
//     //Keep the following vectors also
//     .byte $4a,$f3,$91,$f2,$0e,$f2
//     .byte $50,$f2,$33,$f3,$57,$f1,$ca,$f1
//     .byte $ed,$f6 //STOP vector - Essential to avoid JAM
//     //3286 free bytes here for your pleasure!
//     .fill $cd6, 0


//Shallans memory saving tips
//Autostarting PRG code under $1000
// 3767 bytes free for code
// 254 zero page bytes free for variables
// 18 bytes at $1ed for variables
* = $120 "PROGRAM GROUND ZERO"
Entry:
	ldx #$1f 
	txs    //Push stack down to $100-$11f
	//Start your code HERE (205 bytes up to $1ec)

					// lda            1
					// and            #%11111110  // Paging out BASIC ROM
					// sta            1
					     // lda $01
          //            and #%11111000
          //            ora #%00000101
          //            sta $01
    jmp Pre_Title_Screen
#import "variables1.asm"  // Enough variables to fill in this space

	//This area can be used for runtime vars
	//Once prg is loaded (1ed-1ff = 18 bytes)
	//But is bashed by the loading process
*=* "VARIABLES BASHED BEGIN $1ed"	
* = $1f8 "ENTRY CODE 2 bytes" //Override return from load vector on stack         
	.byte <[Entry-1], >[Entry-1]
	.fill 5,00
*=* "VARIABLES BASHED END $1ff"	
* = $200 "BEGIN $200"
// 	//143 free bytes here
// 	.fill $8f, 0

#import "miscsubquad.asm"

*=$028f "BEGIN $28f - 2 bytes"
	.byte $48,$eb //Prevent keyboard jam
	//131 free bytes here
	//.fill $83, 0 

#import "variables2.asm"	  

*=$314 "IRQ BRK AND NMI VECTORS"   //irq, brk and nmi vectors
					.byte      $31, $ea, $66, $fe, $47,$fe
												//keep the following vectors also
					.byte      $4a,$f3,$91,$f2,$0e,$f2
					.byte      $50,$f2,$33,$f3,$57,$f1,$ca,$f1
					.byte      $ed,$f6 //stop vector - essential to avoid jam
*=* "BEGIN $32a-$3ff"					
												//3286 free .bytes here for your pleasure!
												// .fill $cd6, 0

#import              "4portadapter.asm" 	    // 
#import              "miscsubs.asm"      	    // 

*=* "END $32a-$3ff -end should be $3ff"
*=$0400											// Clear the screen instead of a bunch of zeros
    .fill $3E8, $20								// 

*=$800
*=* "BEGIN Main CODE BLOCK $800-$FFF"

#import "variables_stack.asm"    // Split variables into two files for space savings
#import "maze.asm"
#import "macrosubs.asm"

*=* "BEGIN TITLE SCREEN CODE"

//*******************************************
// Pre-title screen
// Stuff we want initialized once
// not every time
//*******************************************
Pre_Title_Screen:

                   	ldx #24							// Set up low bytes for screen pointer
                 	lda #$c0						// reside in ZP
!:                 	sta scr_off_l,x                 // done backwards saves 1 byte lol
					sec
                   	sbc #40
					dex
                   	bpl !-				

                    lda       #$80                  // Initialize the User Port
                    sta       $dd03                 // cia2 JOY_PORTb bit7 as out
                    lda       $dd01                 // force clock-stretching (supercpu)
                    sta       $dd01                 // and release JOY_PORT
                    lda       #gray2
                   	sta       $d021 
                   	        
//*************************************************************************************
// TITLE SCREEN CODE
// No inputs/outputs
//*************************************************************************************

Title_Screen: {

					jsr       INIT_ALL_VARIABLES   
					inc       ON_Title_Screen       // Make 1, Signify we are in ttl scn to print grd line

					lda       #10            
					sta       MAZE_WIDTH     
					sta       MAZE_HEIGHT    
					jsr       DRAW_MAZE

					ldy       #21             // X pos to start printing text
					ldx       #0              // Y pos to start printing text
					stx       ColorSwapIndex
next_letter:        sty       TEMPY
					ldy       text_index     
					lda       TITLEtext,y    
					beq       ttl_done       
					cmp       #$ff           // Line Feed
					beq       next_line      
					ldy       TEMPY          
 					
				    sta       Char
					jsr       pokeColsxy						
					iny
					inc       text_index     
					bne       next_letter    
next_line:					
					inc       text_index     
					ldy       #21            
					inx
					bne       next_letter    		
ttl_done:
					jsr       SWAP_CQ.SWAP_Color_Quads

					ldy       #19            // Underline the games title
@under:             lda       #99            // Underline char
					sta       ScreenRam+$3c,y
					lda       #yellow
					sta       ColorRam+$14,y 
					dey
					bne       @under       

			        lda 	  Players_C+0 //#green			// Change player number colors
			        sta 	  ColorRam+$221	    // on the title screen
			        lda 	  Players_C+1 //#black
			        sta 	  ColorRam+$271
			        lda 	  Players_C+2
			        sta 	  ColorRam+$2c1
			        lda 	  Players_C+3 // #white
			        sta 	  ColorRam+$311
}

//*********************************************************
// Check if Fire pressed
// Checks all joysticks at once to see if fire is pressed
// Also handles countdown clock after game over
// No Inputs/Outputs
//*********************************************************
Check_Fire:	{	  
					lda       ON_Title_Screen   // Skip this check if on title screen
					bne       @Joy
					lda 	  FrameCounter      // Start count down after  
					cmp 	  #[MAX_FRAMES-1]   // once game is over
					bcc       @Joy

//***********************************************************************************
//                      Countdown code
//***********************************************************************************
					clc 						// Display countdown hi
					lda       #$b0
					adc 	  CountDown+1
					sta       $07e6
					sta       $07c0
					lda       #gray3
					sta       $dbe6
					sta       $dbc0

                 	clc 						// Display countdown low
					lda       #$b0
					adc 	  CountDown
					sta       $07e7
					sta       $07c1
					lda       #gray3
					sta       $dbe7
					sta       $dbc1

					dec 	  CountDown
					bpl 	  @Joy
					lda       #9 
					sta       CountDown
					dec       CountDown+1
					bpl       @Joy
					lda       #Ctr_RESET_TTL_lo   // Countdown at zero - reset it and jump to ttl screen
					sta 	  CountDown
					lda       #Ctr_RESET_TTL_hi
					sta       CountDown+1
				 	jmp       Title_Screen
//***********************************************************************************
@Joy:
    				jsr       JOY_READ       
					lda       JOY_PORT       
					and       [JOY_PORT+1]     
					and       [JOY_PORT+2]     
					and       [JOY_PORT+3]     
					and       #JOY_FIRE     
					beq       BEGIN          
					jsr       UpdateFrameCounter          // Added these 2 lines to
					jsr       Update_Corner_Animations    // keep animation moving while waiting
					jmp       Check_Fire     
}
//********************************************************************
// Begin main program loop
//********************************************************************
*=* "GAME LOOPER CODE"
BEGIN:
//!:
					jsr       INIT_ALL_VARIABLES
					jsr       DRAW_MAZE   					
GameLooper:
					jsr       UpdateFrameCounter
					jsr       JOY_READ 
			  		ldx       #0             
					lda       JOY_PORT       
					jsr       MOVE_DIR       
					ldx       #1             
					lda       [JOY_PORT+1]
					jsr       MOVE_DIR       
					ldx       #2             
					lda       [JOY_PORT+2]     
					jsr       MOVE_DIR       
					ldx       #3             
					lda       [JOY_PORT+3]     
					jsr       MOVE_DIR       
//*****************************************************
//* Moves all 4 PLAYERS
//*****************************************************
					ldy       #3             
@opt_loop:          lda       Player_Char,y
					sta       Char         // Save character to pokeaxy
					lda       Players_C,y    
					sta       CH_Color				
					ldx       Players_Y,y    
					lda       Players_X,y    
					sty       TEMPY          
					tay
					jsr       pokeColsxy    
					ldy       TEMPY  
					dey
					bpl       @opt_loop   
//*****************************************************
//  This game has feature that when any player reaches
//  center of screen the color changes into quads 
//  or four sections on the screen
//  No Inputs/outputs
//*****************************************************
Check_Swap_Colors: {
					ldy       #3                    // Check all 4 players
!:                  lda       QuadColsSwappedyet,y  // Check if already triggered color swap
					bne       @nextloop      
					lda       Players_X,y    
					cmp       #20                   // Has player reached center of screen yet?
					bne       @nextloop      
					lda       #1                    // First time color swap, set to 1 so no repeat
					sta       QuadColsSwappedyet,y
					jsr       SWAP_CQ.SWAP_Color_Quads      // actually do the color change					
					jsr        Sound_Init               // // Evoke color transition sound effect
					jsr        Sounds.Sound_Opt	

@nextloop:          dey
					bpl       !-
donothing:          jsr       Update_Corner_Animations
					jsr       Check_Winner   
					bcc       GameLooper     				
//*****************************************************
//*       Reaches this code after game over
//*****************************************************
					jmp       Check_Fire     		// Too far to save 1 byte :(
}
//*****************************************************
// Moves the player in the direction of ACC
//  Inputs:  Acc = Direction of movement
//        :    x = Current player we are moving
// Outputs: none
//*****************************************************
// Cool down in this context is a term to burn a few cycles
// before allowing user joystick input.  In otherwords
// pause for a bit so when moving, the small gaps are not skipped by
// accident. When skipped makes it more difficult to navigate maze
//*****************************************************
MOVE_DIR:	{		
					sta 	  @joymove          // Dont like doing this...   
					stx       Plr_XIndex    
			        lda       iscooldown,x 		// check if between games and add slight delay
			        beq       @mv			
					lda 	  cooldown,x 		// if cooldown is active then waste some cycles
					beq		  @cooloff
		         	dec       cooldown,x        // wastes a little time until value hits zero
@back:				rts

@cooloff:			lda		  #CoolDown_Speed   // This value determines how long to delay at gaps
					sta	      cooldown,x        // Resetting cooldown values for next time
					lda 	  #0				
					sta	      iscooldown,x
@mv:         		lda       @joymove: #$ff 	// self mod by MOVE_DIR restores joy move
					ldy       Players_Y,x    
					sty       ORIG_Y         
					ldy       Players_X,x    
					sty       ORIG_X   					      
					cmp       #JOY_UP   		// Was joystick up pressed?      
					beq       up             
					cmp       #JOY_DOWN         // Was joystick down pressed? 
					beq       down           
					cmp       #JOY_LEFT         // Was joystick left pressed?
					beq       left           
					cmp       #JOY_RIGHT        // Was joystick right pressed?  
					beq       right 
                    ldy       PrevDir,x         // If Joystick not engaged then continue 
                    beq 	  @back  		    // moving player in the previous direction 
                    tya 				        // it was moving in
                    bpl       MOVE_DIR
Chk_Wall_UPDOWN:  						        // Check for wall vertically	
					lda       Players_Y,x  
					jmp       Shared_ckwal      // Shared with check wall code
Chk_Wall_LEFTRIGHT:							    // Check for wall horizontally
					ldy       Players_X,x    					
					lda       Players_Y,x  
Shared_ckwal:		tax
					jsr       peekxy            // Checking if wall at new pos
					ldx       Plr_XIndex          
					cmp       #Const_WALL    
             		rts
//***************
// Up pressed?
//***************
up:
					sta       PrevDir,x 	    // Up pressed
					dec       Players_Y,x       // Decrease y pos temporiarly
					jsr       Chk_Wall_UPDOWN   // Check if wall at that position
					bne       Exit_CkLFRT       // Did we hit wall?
					inc       Players_Y,x       // Yes, reverse ypos and turn off auto move
					jmp       Shared_wdown      // Shared with down code - turn off cooldown
//***************
// Down pressed?
//***************
down:
					sta 	  PrevDir,x         // Down pressed
					inc       Players_Y,x       // Increase y pos temporiarly
					jsr       Chk_Wall_UPDOWN   // Check if wall at that position
					bne       Exit_CkLFRT       // Did we hit wall? 
					dec       Players_Y,x       // Yes so turn off auto move 
Shared_wdown:		lda       #0                // Turn off cool down once wall hit
					sta       cooldown,x					
					rts
//***************
// Left pressed?
//***************
left:
				    sta 	  PrevDir,x 		 // Left pressed
				    lda       cooldown,x	 	  
					dec       Players_X,x        // Decrease y pos temporiarly	   
					jsr       Chk_Wall_LEFTRIGHT // Check if wall at that position
					bne       Exit_CkUpDN        // Did we hit wall? if not exit
					inc       Players_X,x        // Yes, reverse xpos and turn off auto move
			        jmp  	  Shared_ltrt		 // Share with Right section - Reset cooldown
//***************
// Right pressed?
//***************
right:
				    sta 	  PrevDir,x 		 // Right pressed
					inc       Players_X,x        // Increase y pos temporiarly	
					jsr       Chk_Wall_LEFTRIGHT // Check if wall at that position
					bne       Exit_CkUpDN        // Did we hit wall? if not exit
					dec       Players_X,x        // Yes, reverse xpos and turn off auto move
Shared_ltrt:     	sta       cooldown,x		 // Reset cooldown		                    	
 					rts

// *********************************************************
// This function, for the horizontal moving player will
// check for spaces above and below the current player 
// and stop the auto movement at the gap
// *********************************************************											
Exit_CkUpDN:	    
					ldy       Players_X,x  
					lda       Players_Y,x  
				    tax
				    inx						     // Check for open space BELOW player
					jsr       peekxy             // Load in character from screen
				    cmp       #Const_Space	     // is it a blank space?			    
					beq		  @setprev 	         // if so return back
					dex						     // Check for open space ABOVE player  					
					dex
					jsr       @Shared            // jump to shared code     				  
			        bne       Move_Player_onSC   // above & below current position
					beq 	  @setprev           // Jump to shared cod
Exit_CkLFRT:	    jsr 	  check_left_right   // First check for space
			        bne       Move_Player_onSC 	 // above & below current position
@setprev:      		ldx       Plr_XIndex         // Space detected so set prev dir to 0
					lda 	  #0			     // Which stops auto-movement at
                    sta       PrevDir,x		     // position of the space
                    lda       #CoolDown_Speed    // Set up coolddown
                    sta       cooldown,x                   
                    inc       iscooldown,x
Move_Player_onSC:								 // Clear space after player move
					lda       #Const_Space       // 'space' to poke on screen
					sta       Char               // Save character to pokeaxy

					ldx       ORIG_Y             // Load x,y coords prev saved
					ldy       ORIG_X         
					jmp       pokeColsxy         // Poke character on screen and set color
				 // jsr + rts         
}
//****************************************************
//    Handle the Corner Character Animations
// These got way more complicated than I was hoping
// So, all four corners start out before any player
// moves the color of the player.  Then when
// players 1,2 move they corner colors & numbers swap
// same for players 3,4 to indicate the destination
// No Inputs/Outputs
//****************************************************
Update_Corner_Animations: {
					lda       FrameCounter    		// Frame counter is 96 
					lsr                       		// /2
					lsr                       		// /4
					lsr                      		// /8
					sta       ChFrameIndex    		// Divided by 8 yeilds 12 frames
					lda       ON_Title_Screen 		// Corner animations in diff position on ttl screen
					beq       @Corner12
//*******************************************
// This code executes while on ttl screen
//*******************************************					
					lda       Players_C         	// Opt. Savings to be had here..
					sta       TCORNER1_COL    
					lda       Players_C+1    
					sta       TCORNER2_COL      	// This corner shares same exact space on ttl sc as in game   
					lda       Players_C+2    
					sta       TCORNER3_COL    
					lda       Players_C+3    
					sta       TCORNER4_COL    

					ldx       ChFrameIndex    
					lda       ANIMATION_CHRS,x  	// Load the next animation char based on current frame
					beq       @TNumber          	// If char is 0 then display the player number
					sta       TCORNER1        
					sta       TCORNER2        
					sta       TCORNER3        
					sta       TCORNER4   
                   	rts
@TNumber:											// Display Player #
					lda       #Player1_CH       	// on all 4 four corners
					sta       TCORNER1        
					lda       #Player2_CH           
					sta       TCORNER2        
					lda       #Player3_CH           
					sta       TCORNER3        
					lda       #Player4_CH           
					sta       TCORNER4        
					rts
//************************************************				
// When players move out of corners the animations
// color flips or reverses corners indicating dest
//************************************************
@Corner12:
					lda       moved_fromcorner12    // Check if players 1 or 2 moved from corner yet
					beq       @incorner12
					lda       Players_C 
					sta       GCORNER1_COL    
					lda       Players_C+1
             		sta       GCORNER2_COL  
				    lda       #Player2_CH           // Notice reverse of code just above 
			        sta       GCORNER2 
				    lda       #Player1_CH           
					sta       GCORNER1        
                    jmp       @chk34
@incorner12:		clc 							// If players [1,2] move out of corner
					lda 	  Players_X    			// flip character and color with
					adc 	  Players_X+1 			// Opposite corner to show destination
					adc 	  Players_Y
	                adc 	  Players_Y+1	
					cmp 	  #[RESET_PL1_X]+[RESET_PL2_X]+[RESET_PL1_Y]+[RESET_PL2_Y]
					beq 	  @chk34

@set21:			    lda       Players_C+1
					sta       GCORNER2_COL    
					lda       Players_C
             		sta       GCORNER1_COL   
					lda       #Player2_CH          
					sta       GCORNER2        
				    lda       #Player1_CH           
					sta       GCORNER1        			  
			        inc 	  moved_fromcorner12  // Player 1 or 2 leaves corner
@chk34:
					lda 	  moved_fromcorner34  // Check if players 3 or 4 have moved away from corner
                    beq       @incorner34         // No?  then display player colors in corners
					lda       #Player4_CH         // Notice reverse of code just above
					sta       GCORNER3      
					lda       #Player3_CH          
					sta       GCORNER4    
					lda       Players_C+3
					sta       GCORNER3_COL					
					lda       Players_C+2						
					sta       GCORNER4_COL	
@set34:			
			        inc       moved_fromcorner34	
			        jmp       @chkanim						
@incorner34:
					lda       #Player3_CH           
					sta       GCORNER3      
					lda       #Player4_CH          
					sta       GCORNER4    
					lda       Players_C+2
					sta       GCORNER3_COL
					lda       Players_C +3					
					sta       GCORNER4_COL			        	
					clc 					      // If players [3,4] move out of corner
					lda 	  Players_X+2 		  // flip character and color with
					adc 	  Players_X+3 		  // Opposite corner
					adc 	  Players_Y+2
	                adc 	  Players_Y+3	
					cmp 	  #[RESET_PL3_X]+[RESET_PL4_X]+[RESET_PL3_Y]+[RESET_PL4_Y]
					bne 	  @set34					
@chkanim:
				    ldx       gameover			   // If game over want animations to stop and
				    bne       Clear_Losing_Corner  // only display winning corners

					ldx       ChFrameIndex     	   // Load the next animation char based on current frame
					lda       ANIMATION_CHRS,x
					beq       !+
            		sta       GCORNER1        
					sta       GCORNER2  
					sta       GCORNER3 
					sta       GCORNER4  
!:			    	rts

Clear_Losing_Corner:	  							// This happens at game over. Clear all but winning corners
					ldx 	  #0
					jsr 	  GCorner_Winner
            		sta       GCORNER1        
					ldx 	  #1
					jsr 	  GCorner_Winner
					sta       GCORNER2  
					ldx 	  #3
					jsr 	  GCorner_Winner
					sta       GCORNER3 
    				ldx 	  #2
					jsr 	  GCorner_Winner
					sta       GCORNER4  
!:					rts

//*************************************************
//** Inputs: Acc = Player number index
//** Outputs Acc = Character to display upon return
//*************************************************
GCorner_Winner:				                             // Check which corners are winners or losers
					pha						    
				    lda 	  winners,x
				    beq 	  @notwnner                  // Loser = clear that corner
		      	    pla
		      	    txa
		      	    clc
		      	    adc 	  #Player1_CH                // Display player number of winner
				    rts
@notwnner:			pla
					lda 	  #Const_Space				 // Clear out losing corner
					rts
}

//********************************************
// Has Player made it to opposite corner?
// No Inputs/Outputs
//********************************************
Check_Winner:  {
					ldx       #3             
@Check_another:
					lda       Players_X,x      		// Loop through all players checking
					cmp       Players_Win_X,x  		// if they have made it to their
					bne       @loop_bot        		// winning destination
					lda       Players_Y,x    
					cmp       Players_Win_Y,x
					bne       @loop_bot      
					inc       winners,x      	
@loop_bot:          dex	
					bpl       @Check_another 
					clc
					lda       winners        		// Are there any winners?
					adc       winners+1      		//
					adc       winners+2      		//
					adc       winners+3      		//
					cmp       #1             
					bcs       WINNER         
					clc     			  	 		// Made it here = no winner yet
					rts
//********************************************
//          Winner: Game has been won
//********************************************
WINNER:
					beq       @SingleWinner  
					jsr       Display_Winner 
//******************************************************
//* More than one winner...
//******************************************************
					ldy       #0              	// Modify text at bottom slightly   
					lda       #'s'            	// in the case of a tie
					sta       ScreenRam+$3d2 
					lda       #Const_Space           
					sta       ScreenRam+$3d3 
@next_winner:								 	// This has to be done in order
					lda       winners,y      	// to display PLAYERS 1234 tied!
					beq       @nxt           
					tya
					clc
					adc       #Player1_CH           
					sta       ScreenRam+$3d4,y
				    lda       Players_C,y
			    	sta       ColorRam+$3d4,y
@nxt:
					lda       #Const_Space           
					sta       ScreenRam+$3d5,y
					iny
					cpy       #$4            
					bne       @next_winner   
					ldy       #0             
@loop1:             lda       TIES,y
					beq       !+           
					sta       ScreenRam+$3d8,y
					iny
					bne       @loop1                	
!:					jsr 	  Sounds.Sound_Winner       // Sound for tie game!
					ldx       #12						// Flash effect
				    ldy       #23						// for bottom line				   
					jmp       @flashMSG
//******************************************************
// CODE here = Single winner declared 
// No Inputs/Outputs
//******************************************************
@SingleWinner:     
			        ldx       #3
!:					lda       winners,x
					cmp       #$1            
					beq       @chicken_dinner
					dex
					bpl !-
@chicken_dinner:    jsr       Display_Winner
					lda       Players_C,x
		    		sta       ColorRam+$3d4		    	
                    inx 							// X is the player number/winner here
					txa
					clc
					adc       #[Player1_CH-1]                  // Display player number on screen
					sta       ScreenRam+$3d4 			    		
				    jsr		  Sounds.Sound_Winner
					ldx       #11             		// Produce flashing effect for winner
        			ldy       #14                   // 14 for single winner 23 for ties
@flashMSG:          sty       @horiz			    // at bottom of the screen
!:				    ldy       @horiz: #$ff  	    // SM code
!:                  lda       ScreenRam+$3cc,y
					eor       #$80           
					sta       ScreenRam+$3cc,y
					clc
					lda       ScreenRam+$3d4
					eor       #$80           
				 	sta       ScreenRam+$3d4 
					dey
					bpl       !-
					jsr       delay
					dex
					bne       !--
					sec
					rts
}					
*=* "BEGIN MISC SUB"
					
//********************************************
// After Maze drawn swap out visit characters
// To desired char. visit chars are in
// this case either $a1 or $21. The visits
// show up on the top half of screen
// No Inputs/Outputs
//********************************************
Remove_Visits:  {
                         ldy       #0             
!:
                         lda       ScreenRam,y       
                         jsr       RM_Vis_SUB     
                         sta       ScreenRam,y    
                         lda       ScreenRam+250,y
                         jsr       RM_Vis_SUB 
                         sta       ScreenRam+250,y
                         iny						 // Cannot do this backwards with bpl :(
                         cpy       #250           
                         bne       !-

                         ldy       #18            
@ttl_loop:               lda       ON_Title_Screen   // If on title screen print GRD line
                         beq       @print_racer      // otherwise print games name on bot
                         lda       GRD,y             
                         jmp       @skp           
@print_racer:            lda       TITLEtext,y         // Print games title bottom of maze
@skp:                    beq       !+
                         sta       ScreenRam+$3a2,y
                         lda       #yellow           
                         sta       ColorRam+$3a2,y
                         dey
                         bpl       @ttl_loop      
!:                       rts
RM_Vis_SUB:
                         cmp       #[Const_WALL+1]  // if visit set wall could be 160+1
                         beq       @iswall        
                         cmp       #[Const_Space+1] // if visit was set then bit 0 could be set 32+1
                         bne       !+
                         lda       #Const_Space            
                         rts
@iswall:           
                         lda       #Const_WALL
!:                       rts
}
//********************************************
// Responsible for changing the colors
// in the four quadrants of the screen
// No Inputs/Outputs
//********************************************
SWAP_CQ:  {

SWAP_Color_Quads:                                       // Change colors of screen in one of 4 quadrants
                         ldy       ColorSwapIndex 
                         lda       QuadCols1,y    
                         sta       qc1          
                         iny
                         lda       QuadCols1,y    
                         sta       qc2          
                         iny
                         lda       QuadCols1,y    
                         sta       qc3          
                         iny
                         lda       QuadCols1,y    
                         sta       qc4          
                         iny
                         cpy       #12            // Load colors from 4-12
                         bne       @sk            // bc 0-3 was used on Title screen
                         ldy       #04            // reset back to 04
@sk:                     sty       ColorSwapIndex

                         ldx       #11            
top:                     ldy       #19
inner1:                  stx       TEMPX
                         sty       TEMPY          
                         lda       qc1: #$ff      // SM code
                         sta       CH_Color   
                         jsr       Opt_QuadSub    
                         lda       qc2: #$ff      // SM code
                         sta       CH_Color   
                         clc
                         tya
                         adc       #20            // Half way across screen
                         tay
                         jsr       Opt_QuadSub    
                         lda       qc3: #$ff      // SM code
                         sta       CH_Color   
                         clc
                         txa
                         adc       #12            // ~half way down screen
                         tax
                         jsr       Opt_QuadSub    
                         lda       qc4: #$ff      // SM
                         jsr       Quad4          
                         dey
                         bpl       inner1        
                         dex
                         bpl       top            
                         rts
}

//*****************************************************
// Grab value of screen position located at x,y
// Store result in accumulator
// Inputs :  X, Y  : X is horiz pos, y is vert pos
// returns:  Acc   = Character at pos x,y
//*****************************************************
peekxy:            // 13 bytes
					lda       scr_off_l,x    // Load scr low .byte into $fb
					sta       $fb            
					lda       scr_off_h,x    // Load scr hig .byte into $fc
					sta       $fc            
					lda       ($fb),y        // Load result into acc
					rts
*=* "END Main CODE BLOCK $800-$FFF"		       					