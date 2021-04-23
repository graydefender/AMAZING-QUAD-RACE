//************************************************
//** Gray Defender 11/04/2018
//** Draw Maze - Recursive backtracking algorithm
//** Adapted from:
//   "https://rosettacode.org/"
//************************************************
*=* "Begin MAZE.asm"
DRAW_MAZE: {
//*****************************************************
//** This section starts the maze drawing by
//** placing the first MAZE character on the screen
//** then randomly determines whether to draw the second
//** character on the screen when the program starts
//*****************************************************
                    ADD(x,x,screenx)
                    ADD(y,y,screeny)
                    PokeWallaxy(screenx,screeny) // Draw char on screen
                    lda            #2             // Skip this one randomly 50% OF THE TIME
                    sta            RND_VALUE
                    jsr            RAND
                    beq            !+
                    dey
                    sty            screeny                                             
                    PokeWallaxy(screenx,screeny) // Draw in char on screen on below first one
!:
//*****************************************************
//** DRAW_MAZE_BORDER
//** DRAW BORDER AROUND THE MAZE
//** At the same time this SUB also marks the
//** entire border as having already been "visited"
//*****************************************************
//** This section draws the vert border lines
*=* "MAZE HEIGHT"
                    lda            #0
                    sta            screenx
                    ldx            MAZE_HEIGHT
bloop:              stx            screeny
                    ldy            screenx
                    jsr            Opt_Poke_Visit
                    ADD(screenx,MAZE_WIDTH,visit_left)
                    ldx            screeny
                    ldy            visit_left
                    jsr            Opt_Poke_Visit
                    ADD(MAZE_WIDTH,MAZE_WIDTH,visit_right)                    
                    ADD(MAZE_HEIGHT,screeny,border_x)
                    PokeWallaxy(screenx,screeny)
                    PokeWallaxy(visit_right,screeny)
                    PokeWallaxy(screenx,border_x)
                    PokeWallaxy(visit_right,border_x)

bdown:              ldx            screeny                   
                    dex
                    bpl            bloop     
//*****************************************************
//** Draw Horizontal lines and set border visits
//*****************************************************
                    ldx            MAZE_WIDTH 
                    dex
loop2:              stx            screenx
                    lda            #0
                    sta            screeny
                    ldx            screeny
                    ldy            screenx
                    jsr            Opt_Poke_Visit
                    lda            MAZE_HEIGHT
                    sta            screeny
                    ldx            screeny
                    ldy            screenx
                    jsr            Opt_Poke_Visit
                    lda            #0
                    sta            visit_right
                    ADD(MAZE_HEIGHT,MAZE_HEIGHT,border_y)
                    ADD(screenx,MAZE_WIDTH,visit_left)
                    PokeWallaxy(screenx,visit_right)
                    PokeWallaxy(screenx,border_y)
                    PokeWallaxy(visit_left,visit_right)
                    PokeWallaxy(visit_left,border_y)
                    ldx            screenx
                    dex
                    bpl            loop2                                     
//*****************************************************
//** push the variables x, y onto the "stack"
//*****************************************************
PUSH_STACK:         inc            visit_index
                    ldx            visit_index
                    lda            x
                    sta            STACK_X,x
                    lda            y
                    sta            STACK_Y,x
//*****************************************************
//** Represents lines 1270-1350 in maze1.bas
//*****************************************************
                    ldx            y
                    ldy            x
                    jsr            Opt_Poke_Visit
// ******* Set up x-1 , x+1 , y-1, y+1 *******
AFTER_POP:
                    lda            x
                    sta            visit_right
                    inc            visit_right
                    lda            x
                    sta            visit_left
                    dec            visit_left
                    lda            y
                    sta            visit_down
                    inc            visit_down
                    lda            y
                    sta            visit_up
                    dec            visit_up
//*****************************************************
//** Have we aleady visited up/down/left and right?
//** if so POP the stack / back track
//*****************************************************
                    ldx            y
                    ldy            visit_right
                    jsr            Optimized_Peek
                    beq            RANDOM_DIR
                    ldx            visit_down
                    ldy            x
                    jsr            Optimized_Peek
                    beq            RANDOM_DIR
                    ldx            y
                    ldy            visit_left
                    jsr            Optimized_Peek
                    beq            RANDOM_DIR
                    ldx            visit_up
                    ldy            x
                    jsr            Optimized_Peek
                    beq            RANDOM_DIR
                    bne            EXIT_and_POP_STACK
 Optimized_Peek:    jsr            peekxy                    // only want value of bit 0
                    and            #MAZE_VISIT_BIT 
                    rts
//*****************************************************
// POP variables x, y off of stack
// If no more stack left, then exit program - maze done
//*****************************************************
EXIT_and_POP_STACK:
                    ldx            visit_index
                    lda            STACK_Y,x
                    sta            y
                    lda            STACK_X,x
                    sta            x
                    dec            visit_index
                    lda            visit_index
                    bne            AFTER_POP            
                    beq            @done                      
@done:              jmp            Remove_Visits  

//*****************************************************
//** Randomly check all directions
//** If not visited, then VISIT that spot
//*****************************************************
RANDOM_DIR:         lda            #4        //** Pick random # 0-3
                    sta            RND_VALUE
rnd_loop:           jsr            RAND
                    sta            Z
                    cmp            #0        // STA above does not set zero flag so need this cmp#0
                    beq            CK_UP_ONE //** Check up one
cmp_1:              cmp            #1
                    beq            CK_DOWN_ONE//** Check down
cmp_2:              cmp            #2
                    beq            CK_LEFT_ONE//** Check left
cmp_3:              cmp            #3
                    bne            rnd_loop
//*****************************************************
//* Has Right been visited?
CK_RIGHT_ONE:
                    ldx            y
                    ldy            visit_right
                    jsr            Optimized_Peek
                    beq            Set_Right_Visit
                    bne            RANDOM_DIR

//*****************************************************
//* Has Up been visited?
CK_UP_ONE:
                    ldx            visit_up
                    ldy            x
                    jsr            Optimized_Peek
                    beq            Set_Up_Visit
                    lda            Z
                    jmp            cmp_1
//*****************************************************
//** Set visit flag on top (up) side neighbor and poke
//** wall characters onto the screen display
//*****************************************************
Set_Up_Visit:
                    ldx            visit_up
                    ldy            x
                    jsr            Opt_Poke_Visit
                    dec            y
                    jsr            Set_Visit_SUB
                    dec            screeny
                    lda            #Const_WALL
                    PokeWallaxy(screenx,screeny)
                    jmp            PUSH_STACK
//*****************************************************
//* Has Down been visited?
CK_DOWN_ONE:
                    ldx            visit_down
                    ldy            x
                    jsr            Optimized_Peek
                    beq            Set_Down_Visit
                    lda            Z
                    jmp            cmp_2
//*****************************************************
//** Set visit flag on bottom (down) side neighbor and poke
//** wall characters onto the screen display
//*****************************************************
Set_Down_Visit:
                    ldx            visit_down
                    ldy            x
                    jsr            Opt_Poke_Visit
                    inc            y
                    jsr            Set_Visit_SUB
                    inc            screeny
                    PokeWallaxy(screenx,screeny)
                    jmp            PUSH_STACK
//*****************************************************
//* Has Left been visited?
CK_LEFT_ONE:
                    ldx            y
                    ldy            visit_left
                    jsr            Optimized_Peek
                    beq            Set_Left_Visit
                    lda            Z
                    jmp            cmp_3
//*****************************************************
//** Set visit flag on left side neighbor and poke
//** wall characters onto the screen display
//*****************************************************
Set_Left_Visit:
                    ldx            y
                    ldy            visit_left
                    jsr            Opt_Poke_Visit
                    dec            x
                    jsr            Set_Visit_SUB
                    lda            #Const_WALL
                    dec            screenx
                    jsr            samecode_visitsub
                    jmp            PUSH_STACK
//*****************************************************
//** Set visit flag on right side neighbor and poke
//** wall characters onto the screen display
//*****************************************************
Set_Right_Visit:
                    ldx            y
                    ldy            visit_right
                    jsr            Opt_Poke_Visit
                    inc            x
                    jsr            Set_Visit_SUB
                    inc            screenx
                    lda            #Const_WALL
                    jsr            samecode_visitsub
                    jmp            PUSH_STACK
}

//***********************************************
// Random subs & variables placed here
// when trying to maximize memory below $400
//***********************************************

check_left_right:    // 23 bytes
                    ldy       Players_X,x  
                    lda       Players_Y,x  
                    tax
                    iny                            // Check for open space right side of plr
                    jsr       peekxy        // Load in character from screen   
                    cmp       #Const_Space    // is it a blank space?                
                    beq       @retback         // if so return back
                    dey                           // Check for open space left side of plr                    
                    dey
@Shared:            jsr       peekxy          // Grab character at pos x,y
                    cmp       #Const_Space  // Is it a space?
                    bne       @retback                  
@retback:           rts  

   
music_notes:        .byte        65,77,97,120,97,120,0      // 7 bytes  
scr_off_h:          .fill      25,>ScreenRam+[i*40]   
Players_C:          .byte      yellow,lightgreen,blue,red    // colors           

QuadCols1:
                    .byte     cyan,black,cyan,black
                    .byte     black,white,white,black
                    .byte     white,black,black,white       

*=* "End MAZE.asm"                    