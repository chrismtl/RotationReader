/*
 * led_macros.asm
 *
 *  Created: 30-05-22 19:59:52
 *   Author: Christian SK M
 */
 ;LED_CELL
 ;purpose: store one led in SRAM of color rgb(@0,@1,@2) in z
 .macro LED_CELL
	ldi    a0,@0
	st     z+,a0
	ldi    a0,@1
	st     z+,a0
	ldi    a0,@2
	st     z+,a0
.endmacro

.macro LOW_LED		; STORE GREEN LED FOR LOW GRAPH HEIGHT
	LED_CELL 10,0,0
.endmacro

.macro MEDIUM_LED	; STORE MEDIUM LED FOR MEDIUM GRAPH HEIGHT
	LED_CELL 14,25,0
.endmacro

.macro HIGH_LED		; STORE RED LED FOR HIGH GRAPH HEIGHT
	LED_CELL 0,10,0
.endmacro

; LED_BAR
; purpose: store @0 consecutive leds of color @1,@2,@3 in z
.macro LED_BAR
	line_loop:
		ldi    a0,@1
		st     z+,a0
		ldi    a0,@2
		st     z+,a0
		ldi    a0,@3
		st     z+,a0
		dec @0
		brne line_loop
.endmacro

;============= LED_BAR COLORS ==============
; EMPTY_BAR
; purpose: store @0 empty leds in z
.macro EMPTY_BAR
	LED_BAR @0,0,0,0
.endmacro


; EMPTY_BAR
; purpose: store @0 white leds in z
.macro WHITE_BAR
	LED_BAR @0,5,5,5
.endmacro

;============= DRAW FUNCTIONS ==============
; CLEAR_SCREEN
; purpose: write empty leds on all 64 leds --> clear screen
.macro CLEAR_SCREEN
	ldi zl,low(0x0400)
	ldi zh,high(0x0400)
	ldi w, 64
	EMPTY_BAR w
	ldi zl,low(0x0400)
	ldi zh,high(0x0400)
.endmacro