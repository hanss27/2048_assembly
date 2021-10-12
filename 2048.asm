.model small
.stack 200h
.data
SCORE DW 0
STRMENU1 DB '------2048------','$'
STRMENU2 DB 'START','$'
STRMENU3 DB 'EXIT','$'
COLOR DB ?
CSYM DB '>','$'
CSROW DB ?
CSCOL DB ?
TMP1 DB ?
TMP2 DB ?
LEN DB 0


 
.code
SETCURSOR MACRO R, C    ; fungsi untuk menetakan cursor pada koordinat matrix
    MOV AH, 02H
    XOR BH, BH
    MOV DH, R
    MOV DL, C
    INT 10H 
ENDM

PRINTLINE MACRO STR, COLOR     ; fungsi print line dari string db
	MOV AH, 09H
	MOV AL, ' '
	XOR BH, BH
	MOV BL, COLOR
	MOV CX, 200
	INT 10H
	
    MOV AH, 09H
    LEA DX, STR
    INT 21H 
ENDM

CURSORBLINK MACRO STR
    PRINTLINE STR  
ENDM
    
GETCURSOR PROC
    MOV AH, 03H
    INT 10H
    MOV CSROW, BH
    MOV CSCOL, BL
ENDP

CURSORSELECT MACRO CSROW
    MOV AH, 0
    INT 16H
    CMP AH, 80H         ; select bawah
    JE DOWN
    CMP AH, 72H         ; select atas
    JE UP
    RET
    DOWN :
        MOV CSROW, 5
        SETCURSOR CSROW,12
        PRINTLINE CSYM, 0FH
        RET 
        
    UP : 
        MOV CSROW, 4
        SETCURSOR CSROW,12
        PRINTLINE CSYM, 0FH
        RET
        
ENDM 

.startup
MENU :
	MOV SCORE, 0
	
SETCURSOR 2,10 
PRINTLINE STRMENU1, 0AH    
SETCURSOR 4,14
PRINTLINE STRMENU2, 07H
SETCURSOR 5,14
PRINTLINE STRMENU3, 0CH
SETCURSOR 4, 12

CURSORSELECT CSROW
	
.exit
END