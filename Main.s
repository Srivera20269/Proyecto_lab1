;------------------------------------------------------
;Universidad del Valle de Guatemala
;Autor: Santiago José Rivera Lemus
;Carné: 20269
;Programación de Microcontroladores
;Proyecto de laboratorio 1: Reloj Digital
;------------------------------------------------------
PROCESSOR 16F887
    
; PIC16F887 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = ON            ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

// config statements should precede project file includes.
#include <xc.inc>
#include "macros.inc"   
  
;Definimos las variables globales
GLOBAL	W_TEMP, STATUS_TEMP
GLOBAL	PORT_CONT, horas, minutos, banderas, nibbles, display, MODO
GLOBAL	CONTADORM, CONTADORH, CONTADORD, CONTADORMES, Unidad, Decena, banderaT

PSECT resVect, class=CODE, abs, delta=2
ORG 00h			    ; posición 0000h para el reset
;------------ VECTOR RESET --------------
resetVec:
    PAGESEL MAIN	    ; Cambio de pagina
    GOTO    MAIN
    
PSECT intVect, class=CODE, abs, delta=2
ORG 04h			    ; posición 0004h para interrupciones
;------- VECTOR INTERRUPCIONES ----------
PUSH:
    MOVWF   W_TEMP	    ; Guardamos W
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP	    ; Guardamos STATUS
    
ISR:
    BTFSC   T0IF	    ; Fue interrupción del TMR0? No=0 Si=1
    CALL    INT_TMR0	    ; Si -> Subrutina o macro con codigo a ejecutar
			    ;	cuando se active interrupción de TMR0
  
    BTFSC   RBIF
    CALL    CAMBIO_MODO
    
    BTFSC   TMR1IF
    CALL    INT_TMR1
			    
    
    
POP:
    SWAPF   STATUS_TEMP, W  
    MOVWF   STATUS	    ; Recuperamos el valor de reg STATUS
    SWAPF   W_TEMP, F	    
    SWAPF   W_TEMP, W	    ; Recuperamos valor de W
    RETFIE		    ; Regresamos a ciclo principal
    
    
PSECT code, delta=2, abs
ORG 100h		    ; posición 100h para el codigo
;------------- CONFIGURACION ------------
MAIN:
    CALL    CONFIG_IO	    ; Configuración de I/O
    CALL    CONFIG_RELOJ    ; Configuración de Oscilador
    CALL    CONFIG_TMR0	    ; Configuración de TMR0
    CALL    CONFIG_TMR1
    CALL    CONFIG_INT	    ; Configuración de interrupciones
    BANKSEL PORTD	    ; Cambio a banco 00
       
LOOP:
	;BTFSC	    PORTA, 0
	CALL	    SET_DISPLAYHORA
	;BTFSC	    PORTB, 0
	;GOTO	    $-1
	
	;BTFSC	    PORTA, 1
	;CALL	    SET_DISPLAYFECHA
	;BTFSC	    PORTB, 1
	;GOTO	    $-1
	
	BTFSC	    PORTB, 2
	CALL	    PARA_RELOJ
	BTFSC	    PORTB, 2
	GOTO	    $-1
	
	
	BTFSC	    PORTB, 0
	CALL	    INCREMENTA
	BTFSC	    PORTB, 0
	GOTO	    $-1
	
	BTFSC	    PORTB, 1
	CALL	    DECREMENTA
	BTFSC	    PORTB, 1
	GOTO	    $-1
	
	BTFSC	    PORTB, 3
	CALL	    SIGUE_RELOJ
	BTFSC	    PORTB, 3
	GOTO	    $-1
	
    
    GOTO    LOOP

;--------------------SUBRUTINAS DE CONFIGURACION--------------------------------
CONFIG_RELOJ:
    BANKSEL OSCCON	    ; cambiamos a banco 1
    BSF	    OSCCON, 0	    ; SCS -> 1, Usamos reloj interno
    BCF	    OSCCON, 6
    BSF	    OSCCON, 5
    BSF	    OSCCON, 4	    ; IRCF<2:0> -> 011 500 kHz
    RETURN
    
; Configuramos el TMR0 para obtener un retardo de 50ms
CONFIG_TMR0:
    BANKSEL OPTION_REG	    ; cambiamos de banco
    BCF	    T0CS	    ; TMR0 como temporizador
    BCF	    PSA		    ; prescaler a TMR0
    BSF	    PS2
    BSF	    PS1
    BSF	    PS0		    ; PS<2:0> -> 111 prescaler 1 : 256
    
    RESET_TMR0	248
    RETURN 
    
 CONFIG_IO:
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH	    ; I/O digitales
    
    BANKSEL TRISD
    CLRF    TRISC	    ; PORTC como salida
    
    BCF	    TRISD, 0
    BCF	    TRISD, 1
    BCF	    TRISD, 2
    BCF	    TRISD, 3
    BCF	    TRISD, 4	    ; PORTD como salida
    
    BCF	    TRISA, 0
    BCF	    TRISA, 1
    BCF	    TRISA, 2
    BCF	    TRISA, 5	    
    BCF	    TRISA, 6	    ;PORTA como salida
    
    BSF	    TRISB, 0
    BSF	    TRISB, 1
    BSF	    TRISB, 2
    BSF	    TRISB, 3
    BSF	    TRISB, 4	    ;Habilitamos Puerto B especifico para entradas
    
    BANKSEL PORTD
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTA	    ;Limpiamos los puertos de salida
    
    RETURN
    
CONFIG_TMR1:
    BANKSEL T1CON	    ; Cambiamos a banco 00
    BCF	    TMR1CS	    ; Reloj interno
    BCF	    T1OSCEN	    ; Apagamos LP
    BSF	    T1CKPS1	    ; Prescaler 1:8
    BSF	    T1CKPS0
    BCF	    TMR1GE	    ; TMR1 siempre contando
    BSF	    TMR1ON	    ; Encendemos TMR1
    
    RESET_TMR1 0xC2, 0xF7   ; TMR1 a 1	s
    RETURN
    
CONFIG_INT:
    BANKSEL IOCB
    BSF	IOCB, 4
    
    
    BANKSEL INTCON
    BSF	    GIE		    ; Habilitamos interrupciones
    BSF	    T0IE	    ; Habilitamos interrupcion TMR0
    BCF	    T0IF	    ; Limpiamos bandera de TMR0
    BSF	    RBIE
    BCF	    RBIF
    BCF	    TMR1IF
    RETURN

;-----------------------SUBRUTINAS DE INTERRUPCIÓN-----------------------------
INT_TMR0:
    RESET_TMR0 250			;Reseteamos TMR0
    CALL    MOSTRAR_VALORES		;Llamamos a subrutina para los displays
    RETURN
    
INT_TMR1:
    RESET_TMR1 0xC2, 0xF7		;Reiniciamos TMR1
    INCF	PORT_CONT		;Incrementamos contador
    MOVF	PORT_CONT, W	    
    XORLW	00111100B		;Comparamos valor del contador con 60
    BTFSS	STATUS, 2		;Si la resta es 0, incrementar contador de minutos
    INCF	CONTADORM
    
    CALL	Binario_BCD
    
    
    RETURN

;------------------------SUBRUTINAS--------------------------------------------
CAMBIO_MODO:
    BTFSC   PORTB, 4			;Verificar si esl puerto B pin 4 es apachado
    INCF    MODO			;si esta presionado incrementar variable de modo
    BTFSC   PORTB, 4
    GOTO    $-1				;antirrebotes
    ESTADO_0:
	MOVLW	    1
	SUBWF	    MODO, W	    ;Comparamos la variable de MODO con 1 si son iguales se pasa al Estado 2
	BTFSS	    STATUS, 2
	GOTO	    ESTADO_1
	
	BSF	    PORTA, 0
	BCF	    PORTA, 1
	BCF	    PORTA, 2
	

	BCF	    RBIF

	RETURN

    ESTADO_1: 
	MOVLW	    2			    ;Comparamos la variable de MODO con 1 si son iguales se pasa al Estado 3
	SUBWF	    MODO, W
	BTFSS	    STATUS, 2
	GOTO	    ESTADO_2
	
	BCF	    PORTA, 0
	BSF	    PORTA, 1
	BCF	    PORTA, 2
	
	

	BCF	    RBIF

	RETURN

    ESTADO_2:
	MOVLW	    3		;Comparamos la variable de MODO con 1 si son iguales se pasa al Estado 4
	SUBWF	    MODO, W
	BTFSS	    STATUS, 2
	CALL	    RT_MODO
	
	
	BCF	    PORTA, 0
	BCF	    PORTA, 1
	BSF	    PORTA, 2

	BCF	    RBIF

	RETURN
	
    RT_MODO:
	MOVLW	    4
	SUBWF	    MODO, W
	BTFSS	    STATUS, 2
	RETURN
	
	CLRF	    MODO
	BCF	    RBIF
    
;----------------------SUBRUTINAS DE RELOJ-------------------------------------
MOSTRAR_VALORES:    
    BCF    PORTD, 0
    BCF	   PORTD, 1
    BCF	   PORTD, 2
    BCF	   PORTD, 3
    BCF	   PORTD, 4
    
    BTFSC   banderas, 0
    GOTO    DISPLAY_1
    
    BTFSC   banderas, 1
    GOTO    DISPLAY_2
    
    BTFSC   banderas, 2
    GOTO    DISPLAY_3
    
    BTFSC   banderas, 3
    GOTO    DISPLAY_4
   
    DISPLAY_0:
	MOVF    display+1, W
	MOVWF   PORTC
	BSF	PORTD, 0
	movlw	1
	xorwf	banderas
	
	return
	
    
    DISPLAY_1:
	MOVF    display, W
	MOVWF   PORTC
	BSF	PORTD, 1
	movlw	3
	xorwf	banderas
	return

    
    
    DISPLAY_2:
	MOVF	display+2, W
	MOVWF	PORTC
	BSF	PORTD, 2
	
	movlw	6
	xorwf	banderas
	return
	
    
    
    DISPLAY_3:
	MOVF	display+3, W
	MOVWF	PORTC
	BSF	PORTD, 3
	
	movlw	12
	xorwf	banderas
	
	return
	
    
    
    DISPLAY_4:
	MOVF	display+4, W
	MOVWF	PORTC
	BSF	PORTD, 4
	
	clrf	banderas
	return
	
SET_DISPLAYHORA:
    MOVF    CONTADORH, W
    CALL    TABLA
    MOVWF   display
    
    MOVF    CONTADORH+1, W
    CALL    TABLA
    MOVWF   display+1
    
    MOVF    nibbles+4, W
    CALL    TABLA
    MOVWF   display+2
    
    MOVF    Decena, W
    CALL    TABLA
    MOVWF   display+3
    
    MOVF    Unidad, W
    CALL    TABLA
    MOVWF   display+4
    
    RETURN
    
SET_DISPLAYFECHA:
    MOVF    Decena, W
    CALL    TABLA
    MOVWF   display
    
    MOVF    Unidad, W
    CALL    TABLA
    MOVWF   display+1
    
    MOVF    nibbles+4, W
    CALL    TABLA
    MOVWF   display+2
    
    MOVF    nibbles+3, W
    CALL    TABLA
    MOVWF   display+3
    
    MOVF    nibbles+2, W
    CALL    TABLA
    MOVWF   display+4
    
    RETURN
;-------------------------SUBRUTINAS HORA Y FECHA-------------------------------	
Binario_BCD:
	MOVF	CONTADORM, W
	SUBLW	50
	BTFSS	STATUS, 2
	incf	Unidad
	GOTO	BCD_0
	
BCD_0:
	MOVLW	10
	SUBWF	Unidad, W
	BTFSS	STATUS, 2
	RETURN
	
	GOTO	BCD_1
	
BCD_1:
	MOVWF	Unidad
	INCF	Decena
	MOVLW	10
	SUBWF	Decena, W
	BTFSC	STATUS, 2
	return
	
	;GOTO	BCD_2
	
	
	
BCD_2:
	INCF	CONTADORH+2
	MOVF	CONTADORH+2, W
	XORLW	00011000B
	BTFSC	STATUS, 2
	CALL	LIMPIA
	
	INCF	CONTADORH
	MOVLW	10
	SUBWF	CONTADORH, W
	BTFSS	STATUS, 2
	RETURN
	
	GOTO	BCD_3
	
    RETURN
    
BCD_3:
	MOVWF	CONTADORH
	INCF	CONTADORH+1
	MOVLW	10
	SUBWF	CONTADORH+1, W
	BTFSC	STATUS, 2
	return
    

CICLO:
    INCF    CONTADORM
    CALL    Binario_BCD
    CLRF    PORT_CONT
    
    RETURN
    
LIMPIA:
    CLRF	CONTADORH+2
    CLRF	CONTADORH+1
    CLRF	CONTADORH
    
    RETURN
 
;-------------------------SUBRUTINAS TIMER-------------------------------------
 
    
;-------------------------SUBRUTINAS DE EDICIÓN--------------------------------
INCREMENTA:
    INCF    CONTADORM
    CALL    Binario_BCD
    RETURN
    
DECREMENTA:
    DECF    CONTADORM
    CALL    Binario_BCD
    RETURN
    
;------------------------SUBRUTINAS DE PARAR RELOJ-----------------------------
PARA_RELOJ:
    BCF	    TMR1ON
    BSF	    PORTA, 6
    RETURN
    
SIGUE_RELOJ:
    BSF	    TMR1ON
    BCF	    PORTA, 6
    RETURN
    

	
org  200h   
;-----------------TABLA----------------------------
 TABLA:
    CLRF    PCLATH
    BSF	    PCLATH, 1
    ANDLW   0x0F
    ADDWF   PCL
    RETLW   00111111B
    RETLW   00000110B
    RETLW   01011011B
    RETLW   01001111B
    RETLW   01100110B
    RETLW   01101101B
    RETLW   01111101B
    RETLW   00000111B
    RETLW   01111111B
    RETLW   01101111B
    RETLW   01110111B
    RETLW   01111100B
    RETLW   00111001B
    RETLW   01011110B
    RETLW   01111001B
    RETLW   01110001B