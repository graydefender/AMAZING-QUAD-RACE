//****************************************************************************
//*   Includes MOST variables - not all here
//*   Mostly Contants and Zeropage
//****************************************************************************

.const ScreenRam                = $400
.const ColorRam                 = $d800
.const Visits                   = ScreenRam
.const SR                       = ScreenRam
.const Ctr_RESET_TTL_lo         = 9                    
.const Ctr_RESET_TTL_hi         = 4                    
.const LDY_ABS                  = $b9                   // Needed this label for self mod code to change an sty to ldy
.const STY_ABS                  = $99					// to reuse existing code to save bytes
.const CoolDown_Speed           = 4
.const Const_Space              = 32
.const Const_WALL               = 160
.const SND 						= 54272
.const MAZE_VISIT_BIT           = %00000001             // Visits buffer was combined with $400 using this bit flip
.const MAX_FRAMES               = 96					// 96/8 yields 12 frames          
.const RESET_PL2_Y              = 21				    // Reset Y values for players [1,4]
.const RESET_PL1_Y              = 01
.const RESET_PL3_Y              = 01
.const RESET_PL4_Y              = 21
.const RESET_PL2_X              = 37					// Reset X values for players [1,4]
.const RESET_PL1_X              = 01
.const RESET_PL3_X              = 37
.const RESET_PL4_X              = 01

.const Player1_CH               = $b1 					// Inverse Number 1 used for player 
.const Player2_CH               = $b2 					// Inverse Number 2 used for player 
.const Player3_CH               = $b3 					// Inverse Number 3 used for player 
.const Player4_CH               = $b4 					// Inverse Number 4 used for player 
 
.const RASTER                   = $d012
.const JOY_UP                   = $1e
.const JOY_DOWN                 = $1d
.const JOY_LEFT                 = $1b
.const JOY_RIGHT                = $17
.const JOY_FIRE                 = %00010000             // All fire buttons pressed at once
.const Const_MAZE_WIDTH         = 19                    //  Valid values are 3 up to 20
.const Const_MAZE_HEIGHT        = 11                    //  Default maze size

.label GCORNER2                  = $429
.label GCORNER1                  = $76d                   
.label GCORNER3                  = $44d
.label GCORNER4                  = $749
.label GCORNER2_COL              = $d829				// Same corner in both
.label GCORNER1_COL              = $db6d                // 'G' is for in-game corners
.label GCORNER3_COL              = $d84d
.label GCORNER4_COL              = $db49
.label TCORNER2                  = $70b                   
.label TCORNER1                  = $429 				// 'T' is for Title Screen corners                  
.label TCORNER3                  = $43b
.label TCORNER4                  = $6f9
.label TCORNER2_COL              = $db0b               
.label TCORNER1_COL              = $d829
.label TCORNER3_COL              = $d83b
.label TCORNER4_COL              = $daf9

// Colors
.const black           = $00
.const white           = $01
.const red             = $02
.const cyan            = $03
.const purple          = $04
.const green           = $05
.const blue            = $06
.const yellow          = $07
.const orange          = $08
.const brown           = $09
.const lightred        = $0A
.const gray1           = $0B
.const gray2           = $0C
.const lightgreen      = $0D
.const lightblue       = $0E
.const gray3           = $0F

* = $03 "Temp Storage for ZP" virtual
.label ZP_BEGIN = *
cooldown:               .byte 00,00,00,00   // Cooldown amount per player
iscooldown:             .byte 00,00,00,00   // on/off flag per player 
visit_up:               .byte 00
visit_down:             .byte 00
ChFrameIndex:           .byte 00
Plr_XIndex:				.byte 00
TEMPX:					.byte 00
visit_left:			    .byte 00
ORIG_X:                 .byte 00
visit_right:		    .byte 00
ORIG_Y:				    .byte 00
TEMPY:                  .byte 00
visit_index:		    .byte 00								// Used while drawing maze
text_index:             .byte 00                    // text_index only used on Title screen
screenx: 				.byte 00
screeny:				.byte 00
border_x:				.byte 00
border_y:				.byte 00
Z:                      .byte 00
y:                      .byte 00
x:                      .byte 00
JOY_PORT:               .byte 00,00,00,00           // 4 bytes
winners:                .byte 00,00,00,00           // 4 bytes
MAZE_WIDTH:             .byte 00                    //  Valid values are 3 up to 20
MAZE_HEIGHT:            .byte 00                    //  Default maze size
ColorSwapIndex:         .byte 00                    // Determines which 'cycle' of 4 colors to swap in
ON_Title_Screen:        .byte 00                    // Only used to draw in GRD in title scr
moved_fromcorner12:     .byte 00                    // Has player 1 or 2 moved away from corner
moved_fromcorner34:     .byte 00					// Has players 3 or 4 moved away from corner
FrameCounter:           .byte 00    				
PrevDir:                .byte 00,00,00,00	    	// Previous directions all players
QuadColsSwappedyet:     .byte 00,00,00,00           // Keep track of which qcolors swapped during game 
CountDown:              .byte 00,00
RND_VALUE:				.byte 00
gameover:				.byte 00
Player_Char:            .byte 00,00,00,00           // 4 bytes
Players_X:              .byte 00,00,00,00           // 4 bytes
Players_Y:              .byte 00,00,00,00           // 4 bytes
.label ZP_END = *  
* = $64 "Temp" virtual
scr_off_l:          .fill      25,<ScreenRam+[i*40]

