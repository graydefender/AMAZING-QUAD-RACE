//*****************************************************
//                  Stack VARIABLES
// These are temporary storage for x,y coords strictly
// used while the maze is drawing
// If stack is reduced to 160, program will crash
// if left to run overnight
// My testing indicates for the size of the maze in this
// game the min this fill can be is 164, but that
// is cutting it really close...
//*****************************************************
*=* "Stack Variables BEGIN"
.align $100

STACK_X:           .fill     165,0   // These need to be aligned on $100
STACK_Y:           .fill     165,0   // to save space coding and otherwise

*=* "Stack Variables END"




