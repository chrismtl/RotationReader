/*
 * variables.asm
 *
 *  Created: 09-05-22 11:07:17
 *   Author: Christian SK M
 */
.dseg
;======== Temp ====================
adcl_temp:  .byte 1
adch_temp:  .byte 1
b0_temp: .byte 1

zl_led: .byte 1
zh_led: .byte 1

zl_graph: .byte 1
zh_graph: .byte 1

;========= Frequency Measures =========
counter: .byte 1
frequency: .byte 1
last_frequency: .byte 1

;========= Display Modes ==============
mode: .byte 1
change_mode: .byte 1

;========= Graph ======================
height: .byte 1
graph_start: .byte 1
nb_column: .byte 1
;nb_shift: .byte 1

;========= Flags ======================
hold: .byte 1
break_menu_loop: .byte 1
neg_flag: .byte 1
show_negative_flag: .byte 1
left_flag: .byte 1
right_flag: .byte 1

;============ 0-7 Shift Save containers =================
h0: .byte 1
h1: .byte 1
h2: .byte 1
h3: .byte 1
h4: .byte 1
h5: .byte 1
h6: .byte 1
h7: .byte 1

;============ 8-15 Real Time Height containers ===========
h8: .byte 1
h9: .byte 1
h10: .byte 1
h11: .byte 1
h12: .byte 1
h13: .byte 1
h14: .byte 1
h15: .byte 1

;============ 16-23 Previous Heights containers ==========
h16: .byte 1
h17: .byte 1
h18: .byte 1
h19: .byte 1
h20: .byte 1
h21: .byte 1
h22: .byte 1
h23: .byte 1
