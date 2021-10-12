; Group     ; 
; - 
;  - 
; - 
; - 

.model small
.stack 200h
.data
SCORE DW 0
STRMENU1 DB '------2048------','$'
STRMENU2 DB 'START','$'
STRMENU3 DB 'EXIT','$'
STRBLANK DB ' ','$'
COLOR DB ?
OPTION DB ?
CSYM DB '>','$'
CSROW DB ?
CSCOL DB ?
MAT DB 16 DUP(0)

 
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

  
GETCURSOR PROC
    MOV AH, 03H
    INT 10H
    MOV CSROW, BH
    MOV CSCOL, BL
    RET
ENDP

CURSORSELECT MACRO CSR
    SELECTING:
        MOV AH, 0
        INT 16H
        CMP AH, 50H         ; select bawah
        JE DOWN
        CMP AH, 48H         ; select atas
        JE UP           
        CMP AH, 1CH         ; enter from keyboard
        JE OUTRO      
        JMP SELECTING
    
    UP:
        MOV OPTION, 1            
        MOV CSROW, 4
        PRINTLINE STRBLANK,0FH
        SETCURSOR CSR,12
        PRINTLINE CSYM, 0FH
        SETCURSOR CSR, 14
        PRINTLINE STRMENU2, 07H
        JMP SELECTING
    
    DOWN:
        MOV OPTION, 2
        MOV CSROW, 5
        PRINTLINE STRBLANK,0FH
        SETCURSOR 4,12
        PRINTLINE STRBLANK,0FH
        SETCURSOR CSR,12
        PRINTLINE CSYM, 0FH        
        SETCURSOR CSR, 14
        PRINTLINE STRMENU3, 0CH
        JMP SELECTING 
    OUTRO:
        
ENDM   
    
PLAYFUNC MACRO 
     
ENDM 

DISP_MAT MACRO 
;    SETCURESOR
    
ENDM
 
 
.startup
MENU:
MOV SCORE, 0
             
SETCURSOR 2,10 
PRINTLINE STRMENU1, 0AH    
SETCURSOR 4,14
PRINTLINE STRMENU2, 07H
SETCURSOR 5,14
PRINTLINE STRMENU3, 0CH

CURSORSELECT CSROW 
CMP OPTION, 1
JE PLAY
CMP OPTION, 2
JE EXIT 

JNE MENU

PLAY:
PLAYFUNC 
     
EXIT:
.exit
END
