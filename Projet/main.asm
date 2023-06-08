  ; file	main.asm   target ATmega128L-4MHz-STK300
; purpose project main file
; usage: buttons on PORTC, ws2812 on PORTD (bit 1)
; 20220315 AxS

; === definitions ===
.equ	REFRESH_RATE = 93	; address LCD data register
.equ	PRESCALER	= 5

.cseg
.org 0
	jmp	reset

.org INT0addr
	jmp int0_sri

.org INT1addr
	jmp int1_sri

.org INT2addr
	jmp int2_sri 

.org INT3addr
	jmp int3_sri 

.org OVF0addr
	jmp tim0_ovf

.org ADCCaddr
	jmp ADCCaddr_sra
.org 0x30

; ========interrupt service routines======
int0_sri:
	ldi _w, 0
	sts mode, _w
	reti

int1_sri:
	ldi _w, 1
	sts mode, _w
	reti

int2_sri:
	ldi _w, 1
	sts break_menu_loop, _w
	reti

int3_sri:
	ldi _w, 1
	sts change_mode, _w
	reti

ADCCaddr_sra:
	ldi 	r23, 0x01		; set the flag
	reti

tim0_ovf:
	in _sreg, SREG
	sts b0_temp, b0		;save b0 in temp
	;push every line to the left
	lds _w, h22
	sts h23, _w
	lds _w, h21
	sts h22, _w
	lds _w, h20
	sts h21, _w
	lds _w, h19
	sts h20, _w
	lds _w, h18
	sts h19, _w
	lds _w, h17
	sts h18, _w
	lds _w, h16
	sts h17, _w
	lds _w, h15
	sts h16, _w
	lds _w, h14
	sts h15, _w
	lds _w, h13
	sts h14, _w
	lds _w, h12
	sts h13, _w
	lds _w, h11
	sts h12, _w
	lds _w, h10
	sts h11, _w
	lds _w, h9
	sts h10, _w
	lds _w, h8
	sts h9, _w
	
	;store last frequency
	lds _w, frequency
	sts last_frequency, _w

	;store frequency
	lds _w, counter		;filter counter if >6
	cpi _w, 7
	brlo PC+2
	ldi _w, 6
	sts frequency, _w
	
	lds b0, mode
	sbrs b0, 0	
	rjmp store	;speed mode:		store frequency

	lds b0, last_frequency
	sub _w, b0				;acceleration mode: store frequency - last frequency

	store:
	sts h8, _w

	;reset counter
	clr _w
	sts counter, _w

	lds b0, b0_temp		;restore b0
	out SREG, _sreg
	reti

;============= INCLUDE FILES =============
;Librairies
.include "macros.asm"		; include macro definitions
.include "definitions.asm"	; include register/constant definitions
.include "encoder.asm"		; include encoder routines

;My macros and routines
.include "distance.asm"

.macro CLEAR_GRAPH
	clr w
	sts h0,  w
	sts h1,  w
	sts h2,  w
	sts h3,  w
	sts h4,  w
	sts h5,  w
	sts h6,  w
	sts h7,  w
	sts h8,  w
	sts h9,  w
	sts h10, w
	sts h11, w
	sts h12, w
	sts h13, w
	sts h14, w
	sts h15, w
	sts h16, w
	sts h17, w
	sts h18, w
	sts h19, w
	sts h20, w
	sts h21, w
	sts h22, w
	sts h23, w
.endmacro

reset:
	LDSP	RAMEND			; Load Stack Pointer (SP)
	OUTI	DDRE,0x02		; Connect LED Matrix to PORTE output mode
	OUTI	DDRD, 0x00		; connect Buttons to PORTD, input mode
	OUTI 	ADCSR, (1<<ADEN)+(1<<ADIE)		; AD enable, AD int.
	OUTI ADMUX, 3		; select channel 3

	sei 
	rcall 	LCD_init		; initialize the LCD
	rcall	encoder_init	; initialize the Encoder
		
	;configure timer0's prescaler
	OUTI ASSR, (1<<As0)
	OUTI TCCR0, PRESCALER
	
	;reset LCD
	rcall LCD_clear
	rcall LCD_home

	rjmp menu

menu:
	menu_init:
	;disable INT3	enable INT0, INT1, INT2
	in w, EIMSK
	ori w, 0b00000111
	andi w, 0b11110111
	out EIMSK, w

	;disable timer0
	in w, TIMSK
	andi w,0b11111110
	out TIMSK, w

	;reset flags
	clr w
	sts change_mode, w

	;initialize menu variables
	ldi w, 8
	sts graph_start, w

	menu_loop:
	WAIT_MS	1				;wait 1 milisecond (debouncing)
	rcall	encoder

	;check for left shift
	lds w, left_flag
	cpi w, 0xff
	brne check_right
	lds w, graph_start
	cpi w, 8
	breq PC+2
	rcall shift_left
	rjmp graph_display

	;check for right shift
	check_right:
	lds w, right_flag
	cpi w, 0xff
	brne PC+2
	lds w, graph_start
	cpi w, 0
	breq PC+2
	rcall shift_right
	rjmp graph_display

.include "graph.asm"

	graph_display:
	DRAW_GRAPH
	rjmp
	mode_display

.include "ws2812b_4MHz.asm"
.include "lcd.asm"			; include the LCD routines
.include "printf.asm"		; include formatted printing routines

	mode_display:
	DISPLAY

	CLEAR_A
	ldi a0, 8
	lds w, graph_start
	sub a0, w

	CLEAR_B
	lds b0, mode
	
	cpi b0, 0
	brne show_acc
	show_speed:
	PRINTF LCD
	.db CR, CR,   "Plot : Speed ", LF
	.db "Shift: t-", FDEC2, a, "    ", 0
	rjmp end_menu_loop
	
	show_acc:
	PRINTF LCD
	.db CR, CR,   "Plot : Acclr ", LF
	.db "Shift: t-", FDEC2, a, "    ", 0
	
	end_menu_loop:
	rcall LCD_home
	lds w, break_menu_loop
	sbrs w, 0
	rjmp menu_loop

	;disable INT0 INT1 INT2		enable INT3
	in w, EIMSK
	andi w, 0b1111000
	ori w, 0b00001000
	out EIMSK, w

	;enable timer0
	in w, TIMSK
	ori w,(1<<TOIE0)
	out TIMSK, w

	;reset break_menu_loop and LCD
	clr w
	sts break_menu_loop, w

	;clear graph
	CLEAR_GRAPH

main:
	;CHECK FOR CHANGE MODE
	lds w, change_mode
	sbrc w, 0
	rjmp menu

	
	; PART 2: READ DISTANCE
	READ_DISTANCE
	; ------ 2.3 check if sensor detects something in the valid range
	cpi a1, 0
	brne detect
	rjmp no_detect
detect:
	lds w, hold
	cpi w, 1
	brne inc_counter
	
	rjmp main_end

inc_counter:
	lds _w, counter
	inc _w
	sts counter, _w
	ldi w, 1
	sts hold, w
	rjmp main_end

release:
	;---- set hold to zero
	 clr w
	 sts hold, w

no_detect:
	;reset show_negative_flag
	clr w
	sts show_negative_flag, w

	;----- check for hold reset
	lds w, hold
	sbrc w, 0
	rcall release

	;write tour/s in b
	load_height:
	CLEAR_B
	lds b0, h8			;load height in b0

	cpi b0, 0			;check height sign for display
	brpl load_mode		;height positive
	show_negative:		;height negative
	neg b0
	ldi w, 1
	sts show_negative_flag, w

	load_mode:
	CLEAR_A
	lds a0, mode
				; print formated
	cpi a0, 0
	breq speed

	lds w, show_negative_flag
	cpi w, 1
	breq acceleration_negative
	rjmp acceleration_positive

	speed:
	PRINTF LCD
	.db CR, CR,   "Speed:       ", LF
	.db		 FDEC2, b, " tour/s      ", 0
	rjmp main_end
	acceleration_positive:
	PRINTF LCD
	.db CR, CR,	  "Acceleration:", LF
	.db	" ",	 FDEC2, b, " tour/s2    ", 0
	rjmp main_end
	acceleration_negative:
	PRINTF LCD
	.db CR, CR,	  "Acceleration:", LF
	.db "-", FDEC2, b, " tour/s2    ", 0

main_end:
	DRAW_GRAPH
	DISPLAY

	jmp main