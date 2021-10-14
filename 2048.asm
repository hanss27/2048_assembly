; Group     ; 
; - 
;  - 
; - 
; - 

;JUMPS       ;UNCOMMENT WHEN RUNNING TASM, COMMENT WHEN COMPILING

.model small
.stack 200h
.data
SCORE DW 0
STRMENU1 DB '------2048------','$'
STRMENU2 DB 'START','$'
STRMENU3 DB 'EXIT','$'
STRBLANK DB ' ','$'
STRV DB '|','____','|','____','|','____','|','____','|','$' 
STRP DB '|', '$'
STRSC DB 'score : ','$'    
COLOR DB ?
OPTION DB ?
CSYM DB '>','$'
CSROW DB ?
CSCOL DB ?
MATRIX DW 16 DUP(0)

 
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
        PRINTLINE STRBLANK,0FH  ;print start
        SETCURSOR CSR,12
        PRINTLINE CSYM, 0FH
        SETCURSOR CSR, 14
        PRINTLINE STRMENU2, 07H
        
        SETCURSOR 5,14          ;print exit
        PRINTLINE STRMENU3,0CH
        SETCURSOR 4,19  
        JMP SELECTING
    
    DOWN:
        MOV OPTION, 2
        MOV CSROW, 5
        PRINTLINE STRBLANK,0FH  ;print start
        SETCURSOR 4,12
        PRINTLINE STRBLANK,0FH
        SETCURSOR 4,14
        PRINTLINE STRMENU2,07H
        
                
        SETCURSOR CSR,12        ;print exit
        PRINTLINE CSYM, 0FH        
        SETCURSOR CSR, 14
        PRINTLINE STRMENU3, 0CH
        JMP SELECTING 
    OUTRO:
        
ENDM   
    
PLAYFUNC MACRO MAT
    DISP_MAT MAT 
ENDM

DISP_FRAME_ROW MACRO ROW   
    SETCURSOR ROW, 2
    PRINTLINE STRV, 07H
ENDM

DISP_MAT_ROW MACRO MAT, ROW, INDEX
    MOV SI, [MAT]               ; get array addres of MAT+INDEX 
    SETCURSOR ROW, 2            ; masih error get array valuenya
    PRINTLINE STRP, 07H
    PRINTLINE [SI], 07H
    INC SI
    SETCURSOR ROW, 7
    PRINTLINE STRP, 07H
    PRINTLINE [SI], 07H 
    INC SI
    SETCURSOR ROW, 12
    PRINTLINE STRP, 07H
    PRINTLINE [SI], 07H
    INC SI
    SETCURSOR ROW, 17
    PRINTLINE STRP, 07H
    PRINTLINE [SI], 07H
    INC SI
    SETCURSOR ROW, 22
    PRINTLINE STRP, 07H
    
ENDM

DISP_MAT MACRO MAT
    DISP_FRAME_ROW 2
    DISP_MAT_ROW MAT, 3, 00H
    DISP_FRAME_ROW 4
    DISP_MAT_ROW MAT, 5, 04H
    DISP_FRAME_ROW 6
    DISP_MAT_ROW MAT, 7, 08H
    DISP_FRAME_ROW 8
    DISP_MAT_ROW MAT, 9, 0CH
    DISP_FRAME_ROW 10
    
    SETCURSOR 12,2
    PRINTLINE STRSC, 0AH
ENDM
 
 
.startup

MENU:
MOV SCORE, 0
             
SETCURSOR 2,10             ;set default menu into start
PRINTLINE STRMENU1, 0AH
SETCURSOR 4,12
PRINTLINE CSYM, 0FH    
SETCURSOR 4,14
PRINTLINE STRMENU2, 07H
SETCURSOR 5,14
PRINTLINE STRMENU3, 0CH     
SETCURSOR 4,19
MOV OPTION, 1               

CURSORSELECT CSROW 
CMP OPTION, 1
JE PLAY
CMP OPTION, 2
JE EXIT 

JNE MENU

PLAY:
PLAYFUNC MATRIX
     
EXIT:
.exit
END
