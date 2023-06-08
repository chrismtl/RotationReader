/*
 * distance.asm
 *
 *  Created: 30-05-22 20:08:46
 *   Author: Christian SK M
 */ 
 .macro READ_DISTANCE
	clr r23
	sbi 	ADCSR, ADSC		; AD starts conversion
	WB0		r23, 0		; wait as long as flag reset >flag set in the interrupt >service routine
	in 		a0, ADCL
	in 		a1, ADCH  	; read high byte second
.endmacro