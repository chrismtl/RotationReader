/*
 * graph.asm
 *
 *  Created: 30-05-22 19:56:34
 *   Author: Christian SK M
 */
 
.include "led_macros.asm"

 .macro DRAW_LINE
	;check for negative value
	cpi b0, 0
	brpl color_state_switch
	ldi w, 0xff
	sts neg_flag, w
	neg b0

	color_state_switch:
	cpi b0, 3
	brsh orange_dot
	LOW_LED					;GREEN
	rjmp restore_neg
	orange_dot:
	cpi b0, 5
	brsh red_dot
	MEDIUM_LED				;ORANGE
	rjmp restore_neg
	red_dot:
	HIGH_LED				;RED

	restore_neg:
	lds w, neg_flag
	cpi w, 0xff
	brne end
	neg b0
	clr w
	sts neg_flag, w
	end:
	nop
.endmacro

.macro BAR
	ldi w, 6
	sub w, b0			; Calculate empty leds

	breq draw_height
	EMPTY_BAR w

	draw_height:
	cpi b0, 0
	breq finish		; Height null?
	LED_CELL @0, @1, @2
	cpi b0, 1
	breq finish		; Draw white bar?
	dec b0
	WHITE_BAR b0
		
	finish:
	nop
.endmacro

.macro GRAPH_COLUMN
	;draw bottom line led
	bottom_line:
	sts height, b0
	DRAW_LINE
	
	;draw height
	cpi b0, 0
	brmi red_dot			;

	blue_dot:				;blue dot for positive
	BAR 0,0,10
	rjmp top_line

	red_dot:				;red dot for negative
	neg b0
	BAR 0,10,0

	;draw top line led
	top_line:
	lds b0, height
	DRAW_LINE
.endmacro

.macro DRAW_GRAPH
	;move z pointer back to first led adress
	ldi zl, low(0x400)
	ldi zh, high(0x400)
	
	;draw graphic
	lds b0, h8
	GRAPH_COLUMN
	lds b0, h9
	GRAPH_COLUMN
	lds b0, h10
	GRAPH_COLUMN
	lds b0, h11
	GRAPH_COLUMN
	lds b0, h12
	GRAPH_COLUMN
	lds b0, h13
	GRAPH_COLUMN
	lds b0, h14
	GRAPH_COLUMN
	lds b0, h15
	GRAPH_COLUMN
.endmacro


; shift_left
; purpose: shift whole graph left
shift_left:
	lds w, graph_start
	inc w
	sts graph_start, w

	lds w, h22
	sts h23, w
	lds w, h21
	sts h22, w
	lds w, h20
	sts h21, w
	lds w, h19
	sts h20, w
	lds w, h18
	sts h19, w
	lds w, h17
	sts h18, w
	lds w, h16
	sts h17, w
	lds w, h15
	sts h16, w
	lds w, h14
	sts h15, w
	lds w, h13
	sts h14, w
	lds w, h12
	sts h13, w
	lds w, h11
	sts h12, w
	lds w, h10
	sts h11, w
	lds w, h9
	sts h10, w
	lds w, h8
	sts h9, w
	lds w, h7
	sts h8, w
	lds w, h6
	sts h7, w
	lds w, h5
	sts h6, w
	lds w, h4
	sts h5, w
	lds w, h3
	sts h4, w
	lds w, h2
	sts h3, w
	lds w, h1
	sts h2, w
	lds w, h0
	sts h1, w

	clr w
	sts left_flag, w
	ret


; shift_right
; purpose: shift whole graph right
shift_right:
	lds w, graph_start
	dec w
	sts graph_start, w

	lds w, h1
	sts h0, w
	lds w, h2
	sts h1, w
	lds w, h3
	sts h2, w
	lds w, h4
	sts h3, w
	lds w, h5
	sts h4, w
	lds w, h6
	sts h5, w
	lds w, h7
	sts h6, w
	lds w, h8
	sts h7, w
	lds w, h9
	sts h8, w
	lds w, h10
	sts h9, w
	lds w, h11
	sts h10, w
	lds w, h12
	sts h11, w
	lds w, h13
	sts h12, w
	lds w, h14
	sts h13, w
	lds w, h15
	sts h14, w
	lds w, h16
	sts h15, w
	lds w, h17
	sts h16, w
	lds w, h18
	sts h17, w
	lds w, h19
	sts h18, w
	lds w, h20
	sts h19, w
	lds w, h21
	sts h20, w
	lds w, h22
	sts h21, w
	lds w, h23
	sts h22, w

	clr w
	sts right_flag, w
	ret