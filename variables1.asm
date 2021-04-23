// ************************************************************
// These variables are located in the $123 address Space up to
// $1ec
// ************************************************************
*=* "BEGIN Variables 1"

//*****************************************************
// RANDOM Number SUB
// Inputs: RND_VALUE ZP variable | RND_VALUE is high
// range to select rand number from
// Outputs: Acc - Random value stored there
//*****************************************************
RAND:               // 8 bytes                    
                    lda            $D41B            // get random value from 0-255
                    cmp            RND_VALUE        // narrow random result down                                                       
                    bcs            RAND             // BCS more likely in this program so first
                    rts 
//*****************************************************
// Set a visit sub
// No Inputs / Outputs
//*****************************************************                    
Set_Visit_SUB:       // 22 bytes
                    ADD(x,x,screenx)
                    ADD(y,y,screeny)
samecode_visitsub:  PokeWallaxy(screenx,screeny)
                    rts   
				
TITLEtext:          .text      "a mazing quad race!"
					.byte      $ff                      // Line feeds lol
					.byte      $ff,$ff
					.text      " 4 player support"
					.byte      $ff,$ff
					.text      " race to opposite"
					.byte      $ff,$ff
					.text      "  corner to win"
					.byte      $ff,$ff
					.text      "   press fire"
					.byte      $ff,$ff
					.text      "    to begin"     // FE means move to 'new' x position
					.byte      $ff,$ff
					.text      "    "
				    .byte      Player1_CH					
					.text      " player 1"
					.byte      $ff,$ff
					.text      "    "
					.byte      Player2_CH
					.text      " player 2"
					.byte      $ff,$ff
					.text      "    "
					.byte      Player3_CH					
					.text      " player 3"
					.byte      $ff,$ff					
					.text      "    "
					.byte      Player4_CH					
					.text      " player 4"
					.byte      00

// ************************************************************
// Should end at $1ed
// ************************************************************
*=* "END Variables 1 - should be $1ed"