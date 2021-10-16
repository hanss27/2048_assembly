; Group     ; 
; - 
;  - 
; - 
; - 

JUMPS       ;UNCOMMENT WHEN RUNNING TASM, COMMENT WHEN COMPILING

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
MATRIX DW 512, 512, 1024, 64, 64, 2048, 64, 2, 2, 2, 2, 8, 2, 4, 4, 2 
D0 DW ?
D1 DW ?
D2 DW ?
D3 DW ?
F1 DB ?
F2 DB ?
F3 DB ?
COUNTER DW 0

;=======================================================================================================
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
SETCURSOR 12,10
PRINTLINE STRBLANK, 07H
SETCURSOR 12,10
PRINTNUM SCORE

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

SCORING PROC NEAR   
    ADD BX, AX    
    MOV AX, 0    
    ADD CX, BX 
    RET  
SCORING ENDP


COMPARING MACRO D0, D1, D2, D3, SCORE
    LOCAL CHECK,FLAG1,FLAG2,FLAG3,CORRECT1, CORRECT2, CORRECT3, RETURN
    
    MOV F1, 0   ; SET COMPARE FLAG TO 0
    MOV F2, 0
    MOV F3, 0
    
    MOV CX, SCORE
    CHECK:
    CMP F1, 0
    JE FLAG1
    CMP F2, 0
    JE FLAG2
    CMP F3, 0
    JE FLAG3
    JMP RETURN 

    FLAG1:
    MOV AL, 1
    MOV F1, AL
    MOV AX, D3
    MOV BX, D2
    CMP AX, BX 
    JE CORRECT1
    JMP CHECK
        
    FLAG2:
    MOV AL, 1
    MOV F2, AL
    MOV AX, D2
    MOV BX, D1
    CMP AX, BX        
    JE CORRECT2
    JMP CHECK
        
    FLAG3:
    MOV AL, 1
    MOV F3, AL
    MOV AX, D1
    MOV BX, D0
    CMP AX, BX        
    JE CORRECT3
    JMP CHECK 
     
    CORRECT1:    
    CALL SCORING
    MOV D3, BX
    MOV D2, AX

    JMP CHECK
    
    CORRECT2:
    CALL SCORING    
    MOV D2, BX
    MOV D1, AX  
    JMP CHECK
    
    CORRECT3:
    CALL SCORING    
    MOV D1, BX
    MOV D0, AX     
    JMP CHECK
    
    RETURN:
    MOV SCORE, CX        
ENDM

GET_ROW_VALUE PROC NEAR
    MOV D0 ,0
    MOV D1 ,0
    MOV D2 ,0
    MOV D3 ,0
    
    MOV CX, [SI]   ; [E1]  E2  E3  E4
    MOV D0, CX
    INC SI
    INC SI
    
    MOV CX, [SI]   ;  E1  [E2] E3  E4
    MOV D1, CX
    INC SI
    INC SI

    MOV CX, [SI]   ;  E1   E2 [E3] E4
    MOV D2, CX
    INC SI
    INC SI

    MOV CX, [SI]   ;  E1   E2  E3 [E4]
    MOV D3, CX

    RET
GET_ROW_VALUE ENDP   

GET_COL_VALUE PROC NEAR
    MOV D0 ,0
    MOV D1 ,0
    MOV D2 ,0
    MOV D3 ,0
    
    MOV CX, [SI]   ; [E1]  E5  E9  E13
    MOV D0, CX
    ADD SI,8
    
    MOV CX, [SI]   ;  E1  [E5] E9  E13
    MOV D1, CX
    ADD SI,8

    MOV CX, [SI]   ;  E1   E5 [E9] E13
    MOV D2, CX
    ADD SI,8

    MOV CX, [SI]   ;  E1   E5  E9 [E13]
    MOV D3, CX
    ADD SI,8
    
    RET
GET_COL_VALUE ENDP

ALIGNMAT MACRO  D0, D1, D2, D3, COUNTER
    LOCAL ALIGN1, ALIGN2, ALIGN2F, ALIGN3,ALIGN3F,RETURN
    MOV COUNTER, 1
    MOV AX, D3
    CMP AX, 0
    JE ALIGN1
    JNE ALIGN2F

    ALIGN1:
        MOV AX, COUNTER
        ADD AX, 1
        MOV COUNTER, AX

        MOV BX, D2
        MOV D3, BX
        MOV CX, D1
        MOV D2, CX
        MOV CX, D0
        MOV D1, CX
        MOV D0, 0

        MOV AX, COUNTER
        CMP AX, 4
        JE RETURN

        MOV BX, D3
        CMP BX, 0
        JE ALIGN1
        JNE ALIGN2F

    ALIGN2F:
        MOV AX, COUNTER
        MOV AX, 1
        MOV COUNTER, AX 
        JMP ALIGN2   
    ALIGN2:
        MOV AX, COUNTER
        ADD AX, 1
        MOV COUNTER, AX

        MOV AX, D2
        CMP AX, 0
        JNE ALIGN3

        MOV AX, D1
        MOV BX, D0
        
        MOV D2, AX
        MOV D1, BX
        MOV D0, 0
  
        MOV AX, COUNTER
        CMP AX, 3
        JE RETURN

        MOV AX, D2
        CMP AX, 0
        JE ALIGN2
        JNE ALIGN3F
    ALIGN3F:
        MOV AX, COUNTER
        MOV AX, 1
        MOV COUNTER, AX 
        JMP ALIGN3    
    ALIGN3:
        MOV AX, D1
        CMP AX, 0
        JNE RETURN

        MOV AX, COUNTER
        ADD AX, 1
        MOV COUNTER, AX

        MOV AX, COUNTER
        CMP AX, 2
        JE RETURN

        MOV AX, D0
        MOV D1, AX
        MOV D0, 0
        JMP RETURN
    RETURN:                
ENDM

SHIFT_ROW_RIGHT MACRO MAT, INDEX, SCORE
    ; CLEAN TEMPORARY VARIABLE
    
    LEA SI, MAT 
    ADD SI, INDEX
    ADD SI, INDEX
    
    CALL GET_ROW_VALUE
    
    COMPARING D0, D1, D2, D3, SCORE
    ALIGNMAT D0, D1, D2, D3, COUNTER

    LEA SI, MAT
    ADD SI, INDEX
    ADD SI, INDEX
    
    MOV CX, D0
    MOV [SI], CX
    INC SI
    INC SI
    
    MOV CX, D1
    MOV [SI], CX
    INC SI
    INC SI
    
    MOV CX, D2
    MOV [SI], CX
    INC SI
    INC SI
    
    MOV CX, D3
    MOV [SI], CX
    
ENDM

SHIFT_ROW_LEFT MACRO MAT, INDEX, SCORE
    ; CLEAN TEMPORARY VARIABLE

    LEA SI, MAT 
    ADD SI, INDEX
    ADD SI, INDEX
    
    CALL GET_ROW_VALUE
    
    COMPARING D3, D2, D1, D0, SCORE
    ALIGNMAT D3, D2, D1, D0, COUNTER

    LEA SI, MAT
    ADD SI, INDEX
    ADD SI, INDEX
    
    MOV CX, D0
    MOV [SI], CX
    INC SI
    INC SI
    
    MOV CX, D1
    MOV [SI], CX
    INC SI
    INC SI
    
    MOV CX, D2
    MOV [SI], CX
    INC SI
    INC SI
    
    MOV CX, D3
    MOV [SI], CX

    
ENDM



SHIFT_COL_UP MACRO MAT, INDEX, SCORE
    ; CLEAN TEMPORARY VARIABLE

    LEA SI, MAT 
    ADD SI, INDEX
    ADD SI, INDEX
    
    CALL GET_COL_VALUE
    
    COMPARING D3, D2, D1, D0, SCORE
    ALIGNMAT D3, D2, D1, D0, COUNTER
    LEA SI, MAT
    ADD SI, INDEX
    ADD SI, INDEX
    
    MOV CX, D0
    MOV [SI], CX
    ADD SI, 8
    
    MOV CX, D1
    MOV [SI], CX
    ADD SI, 8
    
    MOV CX, D2
    MOV [SI], CX
    ADD SI, 8
    
    MOV CX, D3
    MOV [SI], CX
    ADD SI, 8
    
ENDM

SHIFT_COL_DOWN MACRO MAT, INDEX, SCORE
    ; CLEAN TEMPORARY VARIABLE

    LEA SI, MAT 
    ADD SI, INDEX
    ADD SI, INDEX
    
    CALL GET_COL_VALUE
    
    COMPARING D0, D1, D2, D3, SCORE
    ALIGNMAT D0, D1, D2, D3, COUNTER
    LEA SI, MAT
    ADD SI, INDEX
    ADD SI, INDEX
    
    MOV CX, D0
    MOV [SI], CX
    ADD SI, 8
    
    MOV CX, D1
    MOV [SI], CX
    ADD SI, 8
    
    MOV CX, D2
    MOV [SI], CX
    ADD SI, 8
    
    MOV CX, D3
    MOV [SI], CX
    ADD SI, 8
    
ENDM

;=======================================================================================================
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

SHIFTING:
MOV AH, 0           ; get arrow movement
INT 16H
CMP AH, 50H         ; PANAH BAWAH
JE ARROWDOWN
CMP AH, 48H         ; PANAH ATAS
JE ARROWUP
CMP AH, 4DH         ; PANAH KANAN
JE ARROWRIGHT
CMP AH, 4BH         ; PANAH KIRI
JE ARROWLEFT
JMP PLAY

ARROWDOWN:
SHIFT_COL_DOWN  MATRIX, 00H, SCORE
SHIFT_COL_DOWN  MATRIX, 01H, SCORE
SHIFT_COL_DOWN  MATRIX, 02H, SCORE
SHIFT_COL_DOWN  MATRIX, 03H, SCORE
JMP PLAY

ARROWUP:
SHIFT_COL_UP  MATRIX, 00H, SCORE
SHIFT_COL_UP  MATRIX, 01H, SCORE
SHIFT_COL_UP  MATRIX, 02H, SCORE
SHIFT_COL_UP  MATRIX, 03H, SCORE
JMP PLAY

ARROWRIGHT:
SHIFT_ROW_RIGHT MATRIX, 00H, SCORE
SHIFT_ROW_RIGHT MATRIX, 04H, SCORE
SHIFT_ROW_RIGHT MATRIX, 08H, SCORE
SHIFT_ROW_RIGHT MATRIX, 0CH, SCORE
JMP PLAY

ARROWLEFT:
SHIFT_ROW_LEFT MATRIX, 00H, SCORE
SHIFT_ROW_LEFT MATRIX, 04H, SCORE
SHIFT_ROW_LEFT MATRIX, 08H, SCORE
SHIFT_ROW_LEFT MATRIX, 0CH, SCORE
JMP PLAY

EXIT:
.exit
END