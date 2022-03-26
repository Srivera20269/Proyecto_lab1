#include <xc.inc>
GLOBAL	W_TEMP, STATUS_TEMP
GLOBAL	PORT_CONT, horas, minutos, banderas, nibbles, display, MODO
GLOBAL	CONTADORM, CONTADORH, CONTADORD, CONTADORMES, Unidad, Decena, banderaT
PSECT udata_shr		    ; Memoria compartida
    W_TEMP:		DS 1
    STATUS_TEMP:	DS 1
    
PSECT udata_bank0
    PORT_CONT:		DS 1
    horas:		DS 2
    minutos:		DS 2
    banderas:		DS 1
    nibbles:		DS 5
    display:		DS 5
    MODO:		DS 1
    CONTADORM:		DS 2
    CONTADORH:		DS 3
    CONTADORD:		DS 2
    CONTADORMES:	DS 2
    Unidad:		DS 1
    Decena:		DS 1
    banderaT:		DS 1
    


