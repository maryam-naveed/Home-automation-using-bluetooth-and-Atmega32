;
; mip final project.asm
;
; Created: 12/15/2021 8:20:38 PM
; 

.INCLUDE "M32DEF.INC"
.CSEG    ;code segment
RJMP MAIN   ;jump main after reset
.ORG URXCaddr 
RJMP URXC_INT_HANDLER
.ORG 40

MAIN:
.EQU LCD_DPRT = PORTC ; LCD DATA PORT
.EQU LCD_DDDR = DDRC ; LCD DATA DDR
.EQU LCD_DPIN = PINC ; LCD DATA PIN
.EQU LCD_CPRT = PORTD ; LCD COMMANDS PORT
.EQU LCD_CDDR = DDRD ; LCD COMMANDS DDR
.EQU LCD_CPIN = PIND ; LCD COMMANDS PIN
.EQU LCD_RS = 2 ; LCD RS
.EQU LCD_RW = 3 ; LCD RW
.EQU LCD_EN = 4 ; LCD EN

LDI R21,HIGH(RAMEND) 
OUT SPH,R21 ; set up stack
LDI R21,LOW(RAMEND)
OUT SPL,R21      
LDI R21,0xFF         ;----------------------r21-------------------
OUT LCD_DDDR, R21  ; LCD  data  port  is  output
OUT LCD_CDDR, R21  ; LCD command port is output 
CBI LCD_CPRT, LCD_EN  ; LCD EN = 0
CALL DELAY_2ms
LDI R16,0x38 ;  2 lines and 5x7 matrix (D0-D7,8-bit)
CALL CMNDWRT ; call command function
CALL DELAY_2ms
LDI R16,0x0E ; display  on,  cursor blinking
CALL CMNDWRT
LDI R16,0x01 ; clear display screen of the LCD
CALL CMNDWRT
CALL DELAY_2ms
LDI R16, 0xFF
OUT DDRD, R16 ; make Port D an output

////////////////////////////////////temp sensor/////////////////////////
LDI R16, 0
OUT DDRA, R16 ; make Port A an input for ADC
LDI R16, 0x87 ; enable ADC and select ck/128
OUT ADCSRA, R16 ; ADCSRA register is the status and control register of ADC.
                ; Bits of this register control or monitor the operation of the ADC. 
LDI R16,0xE0 ; 2.56 V Vref (fixed regardless of Vcc value), ADC0 single-ended
OUT ADMUX, R16 ; ADC multiplexer selection register

//////////////////////////////////////////////motor/////////////////
SBI DDRB,3  ; make PB3 an output 
LDI R16,0x61
OUT TCCR0,R16 ; phase correct PWM, non-inverted

/////////////////////////////////////////////bluetooth//////////////
LDI R16, (1<<RXEN) | (1<<RXCIE) ; enable receiver
OUT UCSRB, R16 ; and RXC interrupt
LDI R16, (1<<UCSZ1) | (1<<UCSZ0) | (1<<URSEL) ; sync,8-bit data
OUT UCSRC, R16 ; no parity, 1 stop bit
LDI R16,0x33 ; 9600 baud rate
OUT UBRRL,R16
SEI

//////////////////////////////led/////////////////////////////////
sbi ddrb , 0
/////////////////////////////////////////////////////////////////////
//r20 = previous temp value
//r25 = starting value of speed
ldi r22,0       ;-----------------------------r22--------------------------
ldi r25,127      ;----------------------------r25---------------------------
;--------------------------------------START----------------------------

ldi r20,0
core:
call temp_display      ;dispaly 'temp:'
call read_adc
call convert_temp ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CALL DATAWRT    ;display temperature
CALL DEGREE      ;display 'degree celsius'

cpi r20 ,  0b11111000   ;fan on
breq k1       ; branch if zero flag is set
cpi r20 ,  0b11111110   ;fan off
breq k2
cpi r20 ,  0b11110000   ;bulb on
breq k3
cpi r20 ,  0b11111001   ;bulb off
breq k4
rjmp core
k1:
call fan_is_on
rjmp core
k2:
call fan_is_off
rjmp core
k3:
sbi portb,0
call led_on
rjmp core
k4:
cbi portb,0
call led_off
rjmp core
rjmp core



fan_is_on:
call temp_display      ; dispaly 'temp:'
//////////////////////////////////////////////////////////////
call read_adc
mov r30,r16      ;------------------------r30-------------------- 
                 ; copies the value in r16 to r30
call temp_and_speed_maping
//////////////////////////////////////////////////////////////
call convert_temp ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CALL DATAWRT    ;display temperature
CALL DEGREE      ;display 'degree celsius'
call FAN_ON      ;display 'fan on'
ret

fan_is_off:
ldi r23,0
out ocr0,r23  
call fan_off
ret

;--------------------------------------END----------------------------------
CMNDWRT:
OUT LCD_DPRT, R16 ; LCD data port = R16 
CBI LCD_CPRT, LCD_RS ; RS 0 for command 
CBI LCD_CPRT, LCD_RW ; RW 0 for write
SBI LCD_CPRT, LCD_EN ; EN = 1 
CALL SDELAY ; make a wide EN pulse 
CBI LCD_CPRT, LCD_EN ; EN=0 for H-to-L pulse
CALL DELAY_100us
RET
DATAWRT:
OUT LCD_DPRT, R16 ; LCD data port = Rl6 
SBI LCD_CPRT, LCD_RS ; RS 1 for data 
CBI LCD_CPRT, LCD_RW ; RW 0 for write
SBI LCD_CPRT, LCD_EN ; EN = 1 
CALL SDELAY
CBI LCD_CPRT, LCD_EN
CALL DELAY_100us
RET

DELAY_100us:
PUSH R17
LDI R17, 60
DR0:
CALL SDELAY
DEC R17
BRNE DR0
POP R17
RET
DELAY_2ms:
PUSH R17
LDI R17, 20
LDR0:
CALL DELAY_100us
DEC R17
BRNE LDR0
POP R17
RET
SDELAY:
NOP ; performs a single-cycle no operation
NOP
RET
;----------------------------------------------

CONVERT_TEMP:

LDI R31,0
ldi r17,0
ldi r19,0


k:
cpi r16,100 ; is it 100 or higher?
brsh l1 ; tests the carry flag and branches if C is cleared 
cpi r16,10 ;is it 10 or higher?
brsh loop
jmp l2

l1:
subi r16 , 100  ; subtract from 100
cpi r16,100 ;is it higher or = to 100?
inc r19     ;--------------------------r19--------------------------
brsh l1  ; it is so keep subtracting
rjmp k ; it is less than 100


LOOP:
SUBI R16, 10 ;subtract from 10
CPi R16, 10 ;is it higher or = to 10?
INC R31         ;---------------------------R31-------------------
BRSH LOOP

l2:
SUBi R16, 1 ;subtract from 1
cpi r16 ,1  ;is it higher or = to 1?
inc r17         ;-----------------------------R17----------------
brsh l2

LDI R21, '0'    ;------------------------r21---------------------
add r19,r21  ;add hundreds with 48
MOV R16, r19 ;display hundreds
CALL DATAWRT

ADD R31, r21  ;add the tens with 48
MOV R16, R31  ;display tens
CALL DATAWRT
ADD r17, r21 ;add the ones with 48
MOV R16, r17 ;display ones
ret

FAN_ON:
LDI R16,0xC0   ; 2nd line
CALL CMNDWRT ; call command function
LDI R16, 'F' ; display letter  
CALL DATAWRT
LDI R16, 'A'
CALL DATAWRT
LDI R16, 'N'
CALL DATAWRT
LDI R16,0x14   ;space
CALL CMNDWRT
LDI R16, 'O'
CALL DATAWRT
LDI R16, 'N'
CALL DATAWRT
LDI R16, ' '
CALL DATAWRT

ret
FAN_OFF:
LDI R16,0xC0   ; 2nd line
CALL CMNDWRT
LDI R16, 'F'
CALL DATAWRT
LDI R16, 'A'
CALL DATAWRT
LDI R16, 'N'
CALL DATAWRT
LDI R16, ' '
CALL DATAWRT
LDI R16, 'O'
CALL DATAWRT
LDI R16, 'F'
CALL DATAWRT
LDI R16, 'F'
CALL DATAWRT
ret

temp_display:
LDI R16,0x80   ; 1st line
CALL CMNDWRT
LDI R16,0x06   ; space
CALL CMNDWRT
LDI R16, 'T'
CALL DATAWRT
LDI R16, 'E'
CALL DATAWRT
LDI R16, 'M'
CALL DATAWRT
LDI R16, 'P'
CALL DATAWRT
LDI R16, ':'
CALL DATAWRT
ret

DEGREE:
LDI R16, 0xDF   ;degree sign
CALL DATAWRT
LDI R16, 'C'    ;celsius
CALL DATAWRT
ret


temp_and_speed_maping:
//r30 has the temp value

cpi r30 , 20   ;less than 20 = fan off
brlo turn_fan_off
cpi r30 , 90   ;greater than 90 = fan max speed
brsh fan_max_speed
rjmp fan_starting_speed   ;temp between 20 and 80

turn_fan_off:
ldi r25,0        ;---------------------------r25------------------------
out ocr0,r25
ret

fan_max_speed:
ldi r25,255 
out ocr0,r25 ; maximum
ret

fan_starting_speed:
cp r30,r22
brlo decrease_speed
breq same_speed
rjmp increase_speed

decrease_speed:
cpi r25 , 0
breq same_speed
dec r25
dec r25
dec r25
rjmp same_speed

increase_speed:
cpi r25 , 255
breq same_speed
inc r25
inc r25
inc r25
rjmp same_speed

same_speed:
mov r22 , r30 ; makes a copy of r30 into r22
out ocr0 , r25
ret

;----------------------------------
READ_ADC:

SBI ADCSRA, ADSC ;start conversion
KEEP_POLING: ;wait for end of conversion
SBIS ADCSRA,ADIF ;is it the end of conversion
RJMP KEEP_POLING ;keep polling till end of conversion
SBI ADCSRA,ADIF ;write 1 to clear ADIF flag
IN R16,ADCH
ret

/////////////////////////////////////////////////////////
URXC_INT_HANDLER:
IN R20,UDR        ;--------------------------r20---------------------------
RETI
; R20=0   fan off
; R20=1   fan on
led_on:
LDI R16,0xC0   ;2nd line
CALL CMNDWRT
LDI R16, 'L'
CALL DATAWRT
LDI R16, 'E'
CALL DATAWRT
LDI R16, 'D'
CALL DATAWRT
LDI R16, ' '
CALL DATAWRT
LDI R16, 'O'
CALL DATAWRT
LDI R16, 'N'
CALL DATAWRT
LDI R16, ' '
CALL DATAWRT
RET

led_off:
LDI R16,0xC0   ; 2nd line
CALL CMNDWRT
LDI R16, 'L'
CALL DATAWRT
LDI R16, 'E'
CALL DATAWRT
LDI R16, 'D'
CALL DATAWRT
LDI R16, ' '
CALL DATAWRT
LDI R16, 'O'
CALL DATAWRT
LDI R16, 'F'
CALL DATAWRT
LDI R16, 'F'
CALL DATAWRT
LDI R16, ' '
CALL DATAWRT
RET

