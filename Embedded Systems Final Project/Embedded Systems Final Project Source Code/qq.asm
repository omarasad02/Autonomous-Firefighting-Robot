
_main:

;qq.c,28 :: 		void main() {
;qq.c,29 :: 		init();
	CALL       _init+0
;qq.c,30 :: 		while(1){
L_main0:
;qq.c,32 :: 		check_right();
	CALL       _check_right+0
;qq.c,33 :: 		check_left();
	CALL       _check_left+0
;qq.c,34 :: 		check_front_obstacle();
	CALL       _check_front_obstacle+0
;qq.c,36 :: 		adjust();
	CALL       _adjust+0
;qq.c,38 :: 		check_fire();
	CALL       _check_fire+0
;qq.c,39 :: 		if (PORTB & 0b10000000){
	BTFSS      PORTB+0, 7
	GOTO       L_main2
;qq.c,40 :: 		PORTD = PORTD | 0b00000010;
	BSF        PORTD+0, 1
;qq.c,41 :: 		my_delay(3000);
	MOVLW      184
	MOVWF      FARG_my_delay_x+0
	MOVLW      11
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,42 :: 		PORTD = PORTD & 0b11111101;
	MOVLW      253
	ANDWF      PORTD+0, 1
;qq.c,43 :: 		my_delay(3000);
	MOVLW      184
	MOVWF      FARG_my_delay_x+0
	MOVLW      11
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,45 :: 		}
L_main2:
;qq.c,46 :: 		}
	GOTO       L_main0
;qq.c,47 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_init:

;qq.c,51 :: 		void init(){
;qq.c,53 :: 		TRISA = 0x01;
	MOVLW      1
	MOVWF      TRISA+0
;qq.c,54 :: 		TRISB = 0b01000000;
	MOVLW      64
	MOVWF      TRISB+0
;qq.c,55 :: 		TRISC = 0x00;
	CLRF       TRISC+0
;qq.c,56 :: 		TRISD = 0b11111101;
	MOVLW      253
	MOVWF      TRISD+0
;qq.c,58 :: 		PORTB = 0x00;
	CLRF       PORTB+0
;qq.c,59 :: 		PORTC = 0x00;
	CLRF       PORTC+0
;qq.c,60 :: 		PORTD = PORTD & 0b11111101;
	MOVLW      253
	ANDWF      PORTD+0, 1
;qq.c,64 :: 		OPTION_REG= 0x87;
	MOVLW      135
	MOVWF      OPTION_REG+0
;qq.c,65 :: 		TMR0=248;// will count 8 times before the overflow (8* 128uS = 1ms)
	MOVLW      248
	MOVWF      TMR0+0
;qq.c,66 :: 		INTCON = 0b11100000; //GIE and , T0IE, peripheral interrupt
	MOVLW      224
	MOVWF      INTCON+0
;qq.c,68 :: 		T1CON=0x01;
	MOVLW      1
	MOVWF      T1CON+0
;qq.c,69 :: 		TMR1H=0;
	CLRF       TMR1H+0
;qq.c,70 :: 		TMR1L=0;
	CLRF       TMR1L+0
;qq.c,72 :: 		CCP1CON=0x08;
	MOVLW      8
	MOVWF      CCP1CON+0
;qq.c,73 :: 		PIE1=PIE1|0x04;// Enable CCP1 interrupts
	BSF        PIE1+0, 2
;qq.c,74 :: 		CCPR1H=2000>>8;
	MOVLW      7
	MOVWF      CCPR1H+0
;qq.c,75 :: 		CCPR1L=2000;
	MOVLW      208
	MOVWF      CCPR1L+0
;qq.c,77 :: 		Hi_Lo_flag = 1;
	MOVLW      1
	MOVWF      _Hi_Lo_flag+0
;qq.c,82 :: 		ADCON0 = 0x41;
	MOVLW      65
	MOVWF      ADCON0+0
;qq.c,83 :: 		ADCON1 = 0xCE;
	MOVLW      206
	MOVWF      ADCON1+0
;qq.c,86 :: 		}
L_end_init:
	RETURN
; end of _init

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;qq.c,92 :: 		void interrupt(){
;qq.c,93 :: 		if(INTCON & 0x04){// TMR0 Overflow interrupt, will get here every 1ms
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt3
;qq.c,94 :: 		TMR0=248;
	MOVLW      248
	MOVWF      TMR0+0
;qq.c,95 :: 		cnt++;
	INCF       _cnt+0, 1
	BTFSC      STATUS+0, 2
	INCF       _cnt+1, 1
;qq.c,96 :: 		cnt1++;
	INCF       _cnt1+0, 1
	BTFSC      STATUS+0, 2
	INCF       _cnt1+1, 1
;qq.c,97 :: 		INTCON = INTCON & 0xFB;//Clear T0IF
	MOVLW      251
	ANDWF      INTCON+0, 1
;qq.c,98 :: 		}
L_interrupt3:
;qq.c,99 :: 		if(PIR1&0x04){//CCP1 interrupt
	BTFSS      PIR1+0, 2
	GOTO       L_interrupt4
;qq.c,100 :: 		if(Hi_Lo_flag){ //high
	MOVF       _Hi_Lo_flag+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_interrupt5
;qq.c,101 :: 		CCPR1H= angle >>8;
	MOVF       _angle+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;qq.c,102 :: 		CCPR1L= angle;
	MOVF       _angle+0, 0
	MOVWF      CCPR1L+0
;qq.c,103 :: 		Hi_Lo_flag=0;//next time low
	CLRF       _Hi_Lo_flag+0
;qq.c,104 :: 		CCP1CON=0x09;//next time Falling edge
	MOVLW      9
	MOVWF      CCP1CON+0
;qq.c,105 :: 		TMR1H=0;
	CLRF       TMR1H+0
;qq.c,106 :: 		TMR1L=0;
	CLRF       TMR1L+0
;qq.c,107 :: 		}
	GOTO       L_interrupt6
L_interrupt5:
;qq.c,109 :: 		CCPR1H= (40000 - angle) >>8;
	MOVF       _angle+0, 0
	SUBLW      64
	MOVWF      R3+0
	MOVF       _angle+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      156
	MOVWF      R3+1
	MOVF       R3+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      CCPR1H+0
;qq.c,110 :: 		CCPR1L= (40000 - angle);
	MOVF       R3+0, 0
	MOVWF      CCPR1L+0
;qq.c,111 :: 		CCP1CON=0x08; //next time rising edge
	MOVLW      8
	MOVWF      CCP1CON+0
;qq.c,112 :: 		Hi_Lo_flag=1; //next time High
	MOVLW      1
	MOVWF      _Hi_Lo_flag+0
;qq.c,113 :: 		TMR1H=0;
	CLRF       TMR1H+0
;qq.c,114 :: 		TMR1L=0;
	CLRF       TMR1L+0
;qq.c,116 :: 		}
L_interrupt6:
;qq.c,118 :: 		PIR1=PIR1&0xFB;
	MOVLW      251
	ANDWF      PIR1+0, 1
;qq.c,119 :: 		}
L_interrupt4:
;qq.c,120 :: 		if(PIR1&0x01){//TMR1 ovwerflow
	BTFSS      PIR1+0, 0
	GOTO       L_interrupt7
;qq.c,122 :: 		PIR1=PIR1&0xFE;
	MOVLW      254
	ANDWF      PIR1+0, 1
;qq.c,123 :: 		}
L_interrupt7:
;qq.c,124 :: 		}
L_end_interrupt:
L__interrupt37:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_read_ATD_A0:

;qq.c,129 :: 		unsigned int read_ATD_A0(){
;qq.c,130 :: 		ADCON0 = ADCON0 | 0x04; // GO
	BSF        ADCON0+0, 2
;qq.c,131 :: 		while(ADCON0 & 0x04);
L_read_ATD_A08:
	BTFSS      ADCON0+0, 2
	GOTO       L_read_ATD_A09
	GOTO       L_read_ATD_A08
L_read_ATD_A09:
;qq.c,132 :: 		return ((ADRESH<<8) | ADRESL);
	MOVF       ADRESH+0, 0
	MOVWF      R0+1
	CLRF       R0+0
	MOVF       ADRESL+0, 0
	IORWF      R0+0, 1
	MOVLW      0
	IORWF      R0+1, 1
;qq.c,133 :: 		}
L_end_read_ATD_A0:
	RETURN
; end of _read_ATD_A0

_my_delay:

;qq.c,136 :: 		void my_delay(int const x){
;qq.c,137 :: 		cnt=0;
	CLRF       _cnt+0
	CLRF       _cnt+1
;qq.c,138 :: 		while(cnt<x);
L_my_delay10:
	MOVLW      128
	XORWF      _cnt+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORWF      FARG_my_delay_x+1, 0
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__my_delay40
	MOVF       FARG_my_delay_x+0, 0
	SUBWF      _cnt+0, 0
L__my_delay40:
	BTFSC      STATUS+0, 0
	GOTO       L_my_delay11
	GOTO       L_my_delay10
L_my_delay11:
;qq.c,140 :: 		}
L_end_my_delay:
	RETURN
; end of _my_delay

_check_right:

;qq.c,142 :: 		void check_right(){
;qq.c,144 :: 		if(PORTD & 0b00010000){
	BTFSS      PORTD+0, 4
	GOTO       L_check_right12
;qq.c,145 :: 		cnt1 = 0;
	CLRF       _cnt1+0
	CLRF       _cnt1+1
;qq.c,147 :: 		while(!(PORTD & 0b10000000)){
L_check_right13:
	BTFSC      PORTD+0, 7
	GOTO       L_check_right14
;qq.c,149 :: 		if (cnt1 >= 5000) break;
	MOVLW      128
	XORWF      _cnt1+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORLW      19
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__check_right42
	MOVLW      136
	SUBWF      _cnt1+0, 0
L__check_right42:
	BTFSS      STATUS+0, 0
	GOTO       L_check_right15
	GOTO       L_check_right14
L_check_right15:
;qq.c,150 :: 		right();
	CALL       _right+0
;qq.c,152 :: 		}
	GOTO       L_check_right13
L_check_right14:
;qq.c,154 :: 		stop();
	CALL       _stop+0
;qq.c,155 :: 		}
L_check_right12:
;qq.c,156 :: 		}
L_end_check_right:
	RETURN
; end of _check_right

_check_front_obstacle:

;qq.c,158 :: 		void check_front_obstacle(){
;qq.c,159 :: 		sensor_voltage = read_ATD_A0();
	CALL       _read_ATD_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;qq.c,162 :: 		while(sensor_voltage >= 100 && sensor_voltage <= 990){
L_check_front_obstacle16:
	MOVLW      0
	SUBWF      _sensor_voltage+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__check_front_obstacle44
	MOVLW      100
	SUBWF      _sensor_voltage+0, 0
L__check_front_obstacle44:
	BTFSS      STATUS+0, 0
	GOTO       L_check_front_obstacle17
	MOVF       _sensor_voltage+1, 0
	SUBLW      3
	BTFSS      STATUS+0, 2
	GOTO       L__check_front_obstacle45
	MOVF       _sensor_voltage+0, 0
	SUBLW      222
L__check_front_obstacle45:
	BTFSS      STATUS+0, 0
	GOTO       L_check_front_obstacle17
L__check_front_obstacle32:
;qq.c,164 :: 		if(!(PORTB & 0b01000000))
	BTFSC      PORTB+0, 6
	GOTO       L_check_front_obstacle20
;qq.c,165 :: 		break;
	GOTO       L_check_front_obstacle17
L_check_front_obstacle20:
;qq.c,166 :: 		sensor_voltage = read_ATD_A0();
	CALL       _read_ATD_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;qq.c,167 :: 		forward();
	CALL       _forward+0
;qq.c,168 :: 		}
	GOTO       L_check_front_obstacle16
L_check_front_obstacle17:
;qq.c,169 :: 		stop();
	CALL       _stop+0
;qq.c,170 :: 		}
L_end_check_front_obstacle:
	RETURN
; end of _check_front_obstacle

_check_left:

;qq.c,172 :: 		void check_left(){
;qq.c,174 :: 		if (PORTD & 0b00100000){
	BTFSS      PORTD+0, 5
	GOTO       L_check_left21
;qq.c,175 :: 		cnt1 = 0;
	CLRF       _cnt1+0
	CLRF       _cnt1+1
;qq.c,177 :: 		while(!(PORTD & 0b10000000)){
L_check_left22:
	BTFSC      PORTD+0, 7
	GOTO       L_check_left23
;qq.c,178 :: 		if (cnt1 >= 5000) break;
	MOVLW      128
	XORWF      _cnt1+1, 0
	MOVWF      R0+0
	MOVLW      128
	XORLW      19
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__check_left47
	MOVLW      136
	SUBWF      _cnt1+0, 0
L__check_left47:
	BTFSS      STATUS+0, 0
	GOTO       L_check_left24
	GOTO       L_check_left23
L_check_left24:
;qq.c,179 :: 		left();
	CALL       _left+0
;qq.c,180 :: 		}
	GOTO       L_check_left22
L_check_left23:
;qq.c,182 :: 		stop();
	CALL       _stop+0
;qq.c,183 :: 		}
L_check_left21:
;qq.c,184 :: 		}
L_end_check_left:
	RETURN
; end of _check_left

_right:

;qq.c,190 :: 		void right(){
;qq.c,191 :: 		PORTC = (PORTC & 0b00001111) | 0b10010000;
	MOVLW      15
	ANDWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      144
	IORWF      R0+0, 0
	MOVWF      PORTC+0
;qq.c,193 :: 		my_delay(4);
	MOVLW      4
	MOVWF      FARG_my_delay_x+0
	MOVLW      0
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,194 :: 		stop();
	CALL       _stop+0
;qq.c,195 :: 		my_delay(4);
	MOVLW      4
	MOVWF      FARG_my_delay_x+0
	MOVLW      0
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,197 :: 		}
L_end_right:
	RETURN
; end of _right

_left:

;qq.c,200 :: 		void left(){
;qq.c,201 :: 		PORTC = (PORTC & 0b00001111)| 0b01100000;
	MOVLW      15
	ANDWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      96
	IORWF      R0+0, 0
	MOVWF      PORTC+0
;qq.c,203 :: 		my_delay(4);
	MOVLW      4
	MOVWF      FARG_my_delay_x+0
	MOVLW      0
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,204 :: 		stop();
	CALL       _stop+0
;qq.c,205 :: 		my_delay(4);
	MOVLW      4
	MOVWF      FARG_my_delay_x+0
	MOVLW      0
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,207 :: 		}
L_end_left:
	RETURN
; end of _left

_stop:

;qq.c,210 :: 		void stop(){
;qq.c,211 :: 		PORTC = PORTC & 0b00001111;
	MOVLW      15
	ANDWF      PORTC+0, 1
;qq.c,212 :: 		}
L_end_stop:
	RETURN
; end of _stop

_forward:

;qq.c,215 :: 		void forward(){
;qq.c,216 :: 		PORTC = (PORTC & 0b00001111)| 0b10100000;
	MOVLW      15
	ANDWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      160
	IORWF      R0+0, 0
	MOVWF      PORTC+0
;qq.c,218 :: 		my_delay(3);
	MOVLW      3
	MOVWF      FARG_my_delay_x+0
	MOVLW      0
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,219 :: 		stop();
	CALL       _stop+0
;qq.c,220 :: 		my_delay(3);
	MOVLW      3
	MOVWF      FARG_my_delay_x+0
	MOVLW      0
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,222 :: 		}
L_end_forward:
	RETURN
; end of _forward

_backward:

;qq.c,224 :: 		void backward(){
;qq.c,225 :: 		PORTC = (PORTC & 0b00001111)| 0b01010000;
	MOVLW      15
	ANDWF      PORTC+0, 0
	MOVWF      R0+0
	MOVLW      80
	IORWF      R0+0, 0
	MOVWF      PORTC+0
;qq.c,227 :: 		my_delay(3);
	MOVLW      3
	MOVWF      FARG_my_delay_x+0
	MOVLW      0
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,228 :: 		stop();
	CALL       _stop+0
;qq.c,229 :: 		my_delay(3);
	MOVLW      3
	MOVWF      FARG_my_delay_x+0
	MOVLW      0
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,230 :: 		}
L_end_backward:
	RETURN
; end of _backward

_adjust:

;qq.c,234 :: 		void adjust(){
;qq.c,235 :: 		sensor_voltage = read_ATD_A0();
	CALL       _read_ATD_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;qq.c,236 :: 		while(sensor_voltage < 100){
L_adjust25:
	MOVLW      0
	SUBWF      _sensor_voltage+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__adjust54
	MOVLW      100
	SUBWF      _sensor_voltage+0, 0
L__adjust54:
	BTFSC      STATUS+0, 0
	GOTO       L_adjust26
;qq.c,237 :: 		backward();
	CALL       _backward+0
;qq.c,238 :: 		sensor_voltage = read_ATD_A0();
	CALL       _read_ATD_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;qq.c,239 :: 		}
	GOTO       L_adjust25
L_adjust26:
;qq.c,240 :: 		stop();
	CALL       _stop+0
;qq.c,241 :: 		}
L_end_adjust:
	RETURN
; end of _adjust

_check_fire:

;qq.c,243 :: 		void check_fire(){
;qq.c,246 :: 		sensor_voltage = read_ATD_A0();
	CALL       _read_ATD_A0+0
	MOVF       R0+0, 0
	MOVWF      _sensor_voltage+0
	MOVF       R0+1, 0
	MOVWF      _sensor_voltage+1
;qq.c,247 :: 		while (PORTD & 0b10000000)
L_check_fire27:
	BTFSS      PORTD+0, 7
	GOTO       L_check_fire28
;qq.c,249 :: 		if(sensor_voltage < 100 || sensor_voltage > 950) break;
	MOVLW      0
	SUBWF      _sensor_voltage+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__check_fire56
	MOVLW      100
	SUBWF      _sensor_voltage+0, 0
L__check_fire56:
	BTFSS      STATUS+0, 0
	GOTO       L__check_fire33
	MOVF       _sensor_voltage+1, 0
	SUBLW      3
	BTFSS      STATUS+0, 2
	GOTO       L__check_fire57
	MOVF       _sensor_voltage+0, 0
	SUBLW      182
L__check_fire57:
	BTFSS      STATUS+0, 0
	GOTO       L__check_fire33
	GOTO       L_check_fire31
L__check_fire33:
	GOTO       L_check_fire28
L_check_fire31:
;qq.c,252 :: 		PORTD = PORTD | 0b00000010;
	BSF        PORTD+0, 1
;qq.c,253 :: 		my_delay(3000);
	MOVLW      184
	MOVWF      FARG_my_delay_x+0
	MOVLW      11
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,254 :: 		PORTD = PORTD & 0b11111101;
	MOVLW      253
	ANDWF      PORTD+0, 1
;qq.c,255 :: 		my_delay(3000);
	MOVLW      184
	MOVWF      FARG_my_delay_x+0
	MOVLW      11
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,258 :: 		angle=3500;
	MOVLW      172
	MOVWF      _angle+0
	MOVLW      13
	MOVWF      _angle+1
;qq.c,259 :: 		my_delay(1500);
	MOVLW      220
	MOVWF      FARG_my_delay_x+0
	MOVLW      5
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,260 :: 		angle=1000;
	MOVLW      232
	MOVWF      _angle+0
	MOVLW      3
	MOVWF      _angle+1
;qq.c,261 :: 		my_delay(1500);
	MOVLW      220
	MOVWF      FARG_my_delay_x+0
	MOVLW      5
	MOVWF      FARG_my_delay_x+1
	CALL       _my_delay+0
;qq.c,262 :: 		}
	GOTO       L_check_fire27
L_check_fire28:
;qq.c,264 :: 		PORTD = PORTD & 0b11111101;
	MOVLW      253
	ANDWF      PORTD+0, 1
;qq.c,265 :: 		angle =  2250;
	MOVLW      202
	MOVWF      _angle+0
	MOVLW      8
	MOVWF      _angle+1
;qq.c,266 :: 		}
L_end_check_fire:
	RETURN
; end of _check_fire
