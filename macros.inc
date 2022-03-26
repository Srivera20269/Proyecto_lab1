#include <xc.inc>
; -------------- MACROS --------------- 
  ; Macro para reiniciar el valor del TMR0
  ; **Recibe el valor a configurar en TMR_VAR**
RESET_TMR0 MACRO TMRVAR
   BANKSEL TMR0	    ; cambiamos de banco
   MOVLW   TMRVAR
   MOVWF   TMR0	    ; configuramos tiempo de retardo
   BCF	   T0IF	    ; limpiamos bandera de interrupción
   ENDM

; Macro para reiniciar el valor del TMR1
; Recibe el valor a configurar en TMR1_H y TMR1_L
;***RESET_TMR1 MACRO TMR1_L, TMR1_H (En clase coloqué intercambiados estos valores)
RESET_TMR1 MACRO TMR1_H, TMR1_L	 ; Esta es la forma correcta
    BANKSEL TMR1H
    MOVLW   TMR1_H	    ; Literal a guardar en TMR1H
    MOVWF   TMR1H	    ; Guardamos literal en TMR1H
    MOVLW   TMR1_L	    ; Literal a guardar en TMR1L
    MOVWF   TMR1L	    ; Guardamos literal en TMR1L
    BCF	    TMR1IF	    ; Limpiamos bandera de int. TMR1
    ENDM


