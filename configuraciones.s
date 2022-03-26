;Configuraciones de proyecto 1
#include <xc.inc>
#include "macros.inc"

GLOBAL	CONFIG_RELOJ, CONFIG_TMR0, CONFIG_IO, CONFIG_TMR1, CONFIG_INT, CONFIG_TMR2
    
PSECT code
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
    BCF	    TRISD, 4
    
    BCF	    TRISA, 0
    BCF	    TRISA, 1
    BCF	    TRISA, 2
    BCF	    TRISA, 5
    
    BSF	    TRISB, 0
    BSF	    TRISB, 1
    BSF	    TRISB, 2
    BSF	    TRISB, 3
    BSF	    TRISB, 4
    
    
    
    BANKSEL PORTD
    CLRF    PORTC
    CLRF    PORTD
    CLRF    PORTA
    
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
    BSF	IOCB0
    BSF	IOCB1
    
    BANKSEL PIE1	    ; Cambiamos a banco 01
    BSF	    TMR1IE	    ; Habilitamos int. TMR1
    BSF	    TMR2IE	    ; Habilitamos int. TMR1
    
    
    BANKSEL INTCON
    BSF	    GIE		    ; Habilitamos interrupciones
    BSF	    T0IE	    ; Habilitamos interrupcion TMR0
    BCF	    T0IF	    ; Limpiamos bandera de TMR0
    BSF	    RBIE
    BCF	    RBIF
    BCF	    TMR1IF
    RETURN
    
    CONFIG_TMR2:
    BANKSEL PR2		    ; Cambiamos a banco 01
    MOVLW   122 	    ; Valor para interrupciones cada 50ms
    MOVWF   PR2		    ; Cargamos litaral a PR2
    
    BANKSEL T2CON	    ; Cambiamos a banco 00
    BSF	    T2CKPS1	    ; Prescaler 1:16
    BSF	    T2CKPS0
    
    BSF	    TOUTPS3	    ;Postscaler 1:13
    BSF	    TOUTPS2
    BCF	    TOUTPS1
    BCF	    TOUTPS0
    
    BSF	    TMR2ON	    ; Encendemos TMR2
    
    
    
    RETURN


