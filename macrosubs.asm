
//*****************************************************
//Macro: Add first two parameters and store in 3rd
//Inputs:  Param1, Param 2
//Outputs: result stored in third param 
//*****************************************************
.macro ADD (value1,value2,result) {
				
                    clc
                    lda            value1
                    adc            value2
                    sta            result

}
//*****************************************************
// Poke a Wall character on the screen at position
// x,y taking into consideration, that space on the
// screen may also have a visit stored there.. since
// screen and visits are sharing the same memory space
//Inputs:  x,y
//Outputs: none
//*****************************************************
.macro PokeWallaxy (xpos,ypos) {
                    ldx          ypos             // X value
                    ldy          xpos             // Y value
                    jsr          PokeWall_Sub
}

