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
MATRIX DW 2048, 1024, 2022, 64, 1024, 2048, 64, 2048, 1024, 2048, 64, 12, 13, 14, 15, 16 
D0 DW ?
D1 DW ?
D2 DW ?
D3 DW ?


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
LEA SI, MAT
ADD SI, INDEX
ADD SI, INDEX               ; get array addres of MAT+INDEX
SETCURSOR ROW, 2            ; masih error get array valuenya
PRINTLINE STRP, 07H
PRINTNUM [SI]
INC SI
INC SI
SETCURSOR ROW, 7
PRINTLINE STRP, 07H
PRINTNUM [SI]
INC SI
INC SI
SETCURSOR ROW, 12
PRINTLINE STRP, 07H
PRINTNUM [SI]
INC SI
INC SI
SETCURSOR ROW, 17
PRINTLINE STRP, 07H
PRINTNUM [SI]
INC SI
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

PRINTNUM MACRO NUM
    LOCAL DIVIDE, PRINT
        MOV CX, NUM
        MOV D3, 0
        MOV D2, 0
        MOV D1, 0
        MOV D0, 0
    DIVIDE:
        MOV AH, 0     ; 2048
        MOV AX, CX
        MOV BX, 10
        XOR DX, DX
        DIV BX
        MOV AH, 0
        MOV CX, AX
        MOV D0, DX
        CMP CX, 0
        JE PRINT
        MOV AH, 0     ; 204
        MOV AX, CX
        MOV BX, 10
        XOR DX, DX
        DIV BX
        MOV AH, 0
        MOV CX, AX
        MOV D1, DX
        CMP CX, 0
        JE PRINT  
        MOV AH, 0
        MOV AX, CX
        MOV BX, 10
        XOR DX, DX
        DIV BX
        MOV AH, 0
        MOV CX, AX
        MOV D2, DX
        CMP CX, 0
        JE PRINT
        MOV AH, 0
        MOV AX, CX
        MOV BX, 10
        XOR DX, DX
        DIV BX
        MOV AH, 0
        MOV CX, AX
        MOV D3, DX
        CMP CX, 0
        JE PRINT
    PRINT:
        MOV DX, D3
        MOV DH, 0 
        MOV AH, 2
        ADD DL, 48
        INT 21H
        MOV DX, D2
        MOV DH, 0
        MOV AH, 2
        ADD DL, 48
        INT 21H
        MOV DX, D1
        MOV DH, 0
        MOV AH, 2
        ADD DL, 48
        INT 21H
        MOV DX, D0
        MOV DH, 0
        MOV AH, 2
        ADD DL, 48
        INT 21H        
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
