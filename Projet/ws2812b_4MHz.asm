/*
 * ws2812b_4MHz.asm
 *
 *  Created: 30-05-22 20:04:45
 *   Author: Christian SK M
 */

 ; WS2812b4_WR0	; macro ; arg: void; used: void
; purpose: write an active-high zero-pulse to PD1
.macro	WS2812b4_WR0
	clr u
	sbi PORTE, 1
	out PORTE, u
	nop
	nop
	;nop	;deactivated on purpose of respecting timings
	;nop
.endm

; WS2812b4_WR1	; macro ; arg: void; used: void
; purpose: write an active-high one-pulse to PD1
.macro	WS2812b4_WR1
	sbi PORTE, 1
	nop
	nop
	cbi PORTE, 1
	;nop	;deactivated on purpose of respecting timings
	;nop

.endm

 .macro DISPLAY 
	restart:
		ldi zl,low(0x0400)
		ldi zh,high(0x0400)

	_LDI	r0,64
	loop:
		ld a0, z+
		ld a1, z+
		ld a2, z+

		cli
		rcall ws2812b4_byte3wr
		sei

		dec r0
		brne loop
	rcall ws2812b4_reset
.endm

 ; ws2812b4_init		; arg: void; used: r16 (w)
; purpose: initialize AVR to support ws2812

; ws2812b4_byte3wr	; arg: a0,a1,a2 ; used: r16 (w)
; purpose: write contents of a0,a1,a2 (24 bit) into ws2812, 1 LED configuring
;     GBR color coding, LSB first
ws2812b4_byte3wr:

	ldi w,8
ws2b3_starta0:
	sbrc a0,7
	rjmp	ws2b3w1
	WS2812b4_WR0			; write zero
	rjmp	ws2b3_nexta0
ws2b3w1:
	WS2812b4_WR1
ws2b3_nexta0:
	lsl a0
	dec	w
	brne ws2b3_starta0

	ldi w,8
ws2b3_starta1:
	sbrc a1,7
	rjmp	ws2b3w1a1
	WS2812b4_WR0			; write a zero
	rjmp	ws2b3_nexta1
ws2b3w1a1:
	WS2812b4_WR1
ws2b3_nexta1:
	lsl a1
	dec	w
	brne ws2b3_starta1

	ldi w,8
ws2b3_starta2:
	sbrc a2,7
	rjmp	ws2b3w1a2
	WS2812b4_WR0			; write a zero
	rjmp	ws2b3_nexta2
ws2b3w1a2:
	WS2812b4_WR1
ws2b3_nexta2:
	lsl a2
	dec	w
	brne ws2b3_starta2
	
ret

; ws2812b4_reset	; arg: void; used: r16 (w)
; purpose: reset pulse, configuration becomes effective
ws2812b4_reset:
	cbi PORTE, 1
	WAIT_US	50 	; 50 us are required, NO smaller works
ret