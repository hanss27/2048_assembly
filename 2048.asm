; Group 19    ; 
; - Fauzan Valdera
; - Louis M D Wijaya 
; - M Fadhil Al Hafiz
; - Raihan M Syahran

; 2048 ;


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
STRWIN DB 'YOU WIN!!', '$'
STRLOSE DB 'YOU LOSE!!', '$'    
COLOR DB ?
OPTION DB ?
CSYM DB '>','$'
CSROW DB ?
CSCOL DB ?
MATRIX DW 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
;MATRIX DW 1024, 1024, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0      ;Check kondisi menang

D0 DW 1                                            
D1 DW ?
D2 DW ?
D3 DW 1
F1 DB ?
F2 DB ?
F3 DB ? 
F4 DB ?
WIN DB ?
LOSE DB ?
COUNTER DW 0    
VALUE DW ?     
REMAINDER DB 0

;=======================================================================================================
.code
SETCURSOR MACRO R, C            ; fungsi untuk menetakan cursor pada koordinat matrix
MOV AH, 02H                     ; masukan ke mode set cursor
XOR BH, BH
MOV DH, R                       ; posisikan cursor di lokasi baris = R
MOV DL, C                       ; posisikan cursor di lokasi kolom = C
INT 10H
ENDM

PRINTLINE MACRO STR, COLOR      ; fungsi print line dari string db
MOV AH, 09H                     ; masuk ke mode print
MOV AL, ' '
XOR BH, BH                    
MOV BL, COLOR                   ; masukan kode warna dalam hexa
MOV CX, 200
INT 10H                         
MOV AH, 09H
LEA DX, STR                     ; masukan address dari STR (string yang dipassing)
INT 21H                         ; print STR
ENDM



CURSORSELECT MACRO CSR
    SELECTING:
    MOV AH, 0                   ; mendapatkan input dari keyboard
    INT 16H
    
    CMP AH, 50H                 ; komparasi dengan arrow bawah
    JE DOWN

    CMP AH, 48H                 ; komparasi dengan arrow atas
    JE UP

    CMP AH, 1CH                 ; mendapatkan input dari keyboard
    JE OUTRO     
    JMP SELECTING

    UP:                         ; Fungsi UP, tampilkan menu dengan cursorsymbol di START
    MOV OPTION, 1
    MOV CSROW, 4
    PRINTLINE STRBLANK,0FH      
    SETCURSOR CSR,12
    PRINTLINE CSYM, 0FH
    SETCURSOR CSR, 14
    PRINTLINE STRMENU2, 07H
    SETCURSOR 5,14              
    PRINTLINE STRMENU3,0CH
    SETCURSOR 4,19
    JMP SELECTING

    DOWN:                       ; Fungsi DOWN, tampilkan menu dengan cursorsymbol di EXIT
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

PRINTNUM MACRO NUM                                      ;Display angka max. 4 digit pada background matrix d
    LOCAL DIVIDE, PRINT4, PRINT3, PRINT2, PRINT1, EX
        MOV CX, NUM
        MOV D3, 0
        MOV D2, 0
        MOV D1, 0
        MOV D0, 0
    DIVIDE:                                             ; mengambil angak per digit
        MOV AH, 0                                       ; angka dari digit satuan dan disimpan pada variabel D0                          
        MOV AX, CX
        MOV BX, 10
        XOR DX, DX
        DIV BX
        MOV AH, 0
        MOV CX, AX
        MOV D0, DX      
        CMP CX, 0
        JE PRINT1
        MOV AH, 0                                       ; angka dari digit puluhan dan disimpan pada variabel D1
        MOV AX, CX
        MOV BX, 10
        XOR DX, DX
        DIV BX
        MOV AH, 0
        MOV CX, AX
        MOV D1, DX    
        CMP CX, 0
        JE PRINT2  
        MOV AH, 0                                        ; angka dari digit ratusan dan disimpan pada variabel D2
        MOV AX, CX                      
        MOV BX, 10
        XOR DX, DX
        DIV BX
        MOV AH, 0
        MOV CX, AX
        MOV D2, DX      
        CMP CX, 0
        JE PRINT3
        MOV AH, 0                                       ; angka dari digit ribuan dan disimpan pada variabel D3
        MOV AX, CX
        MOV BX, 10
        XOR DX, DX
        DIV BX
        MOV AH, 0
        MOV CX, AX
        MOV D3, DX      
        CMP CX, 0
        JE PRINT4
    PRINT4:
        PRINTN D3                                       ; jika tidak ada yang nol, maka di print seluruh nya, i.e 2048
        PRINTN D2
        PRINTN D1
        PRINTN D0 
        JMP EX
    PRINT3:      
        PRINTN D2                                       ; jika tidak ada yang nol, maka di print seluruh nya, i.e 2048
        PRINTN D1
        PRINTN D0
        JMP EX
    PRINT2:      
        PRINTN D1
        PRINTN D0
        JMP EX
    PRINT1:      
        PRINTN D0
        JMP EX
    EX:
          
ENDM  

PRINTN MACRO D
    MOV DX, D
    MOV DH, 0
    MOV AH, 2
    ADD DL, 48
    INT 21H
ENDM

PLAYFUNC MACRO MAT
DISP_MAT MAT
ENDM

DISP_MAT MACRO MAT
DISP_FRAME_ROW 2
DISP_MAT_ROW MAT, 3, 00H                    ; display matrix baris pertama
DISP_FRAME_ROW 4
DISP_MAT_ROW MAT, 5, 04H                    ; display matrix baris kedua
DISP_FRAME_ROW 6
DISP_MAT_ROW MAT, 7, 08H                    ; display matrix baris ketiga
DISP_FRAME_ROW 8
DISP_MAT_ROW MAT, 9, 0CH                    ; display matrix baris keempat
DISP_FRAME_ROW 10

SETCURSOR 12,2                             
PRINTLINE STRSC, 0AH
SETCURSOR 12,10
PRINTLINE STRBLANK, 07H
SETCURSOR 12,10
PRINTNUM SCORE                              ; Print nilai score
ENDM 

DISP_FRAME_ROW MACRO ROW
SETCURSOR ROW, 2
PRINTLINE STRV, 07H
ENDM

DISP_MAT_ROW MACRO MAT, ROW, INDEX          ; Display Matrix
    LEA SI, MAT                             ; mendapatkan address matrix
    ADD SI, INDEX                           ; menambahkan SI dengan Index, sebanyak 2 kali (karena size dw)
    ADD SI, INDEX               
    SETCURSOR ROW, 2                        ; Print nilai matriks pada baris 1
    PRINTLINE STRP, 07H                     ; Print bagian pembatas antar baris matrikx
    PRINTNUM [SI]                           
    INC SI
    INC SI
    SETCURSOR ROW, 7                        ; Print nilai matriks pada baris 2
    PRINTLINE STRP, 07H
    PRINTNUM [SI]
    INC SI
    INC SI
    SETCURSOR ROW, 12                       ; Print nilai matriks pada baris 3
    PRINTLINE STRP, 07H
    PRINTNUM [SI]
    INC SI
    INC SI
    SETCURSOR ROW, 17                       ; Print nilai matriks pada baris 4
    PRINTLINE STRP, 07H
    PRINTNUM [SI]
    INC SI
    INC SI
    SETCURSOR ROW, 22
    PRINTLINE STRP, 07H
ENDM
   

RANDOM_POPUP MACRO NEAR                     ; Fungsi untuk random nilai 2 dan 4 muncul dalam matriks yang kosong
    LOCAL GETTIME, RANDOMIZE, FOUR, SEARCHING, INCREMENT, RESET, NEXT, PLACEVAL, LAST         
    LEA SI, MATRIX			
    MOV CX, 16   
    GETTIME:                
        MOV AH, 2CH
        INT 21H
    RANDOMIZE:      ; Random nilai 2 / 4  di matriks yang kosong
        MOV AX,0
        MOV AL, DL
        MOV DL, 16
        DIV DL  
        MOV REMAINDER, AH
        SHR AH, 1
        JC FOUR
        MOV VALUE, 2
        JMP SEARCHING
    FOUR: 
        MOV VALUE, 4     
    SEARCHING:      ; Search matriks yang kosong
        MOV AX, 0
        MOV AL, REMAINDER
        ADD SI, AX         
        ADD SI, AX
        CMP [SI], 0
        JE PLACEVAL  
        CMP SI, 32
        JE RESET
    INCREMENT:      ; Pindah posisi matriks
        INC SI        
        INC SI        
        JMP NEXT
    RESET:
        LEA SI, MATRIX
    NEXT:
        LOOP SEARCHING
    PLACEVAL:       ; Masukkan value ke matriks
        MOV DX, VALUE
        MOV [SI], DX
        JMP LAST
    LAST:
ENDM

ALIGNMAT MACRO  D0, D1, D2, D3, COUNTER                     ; Align Function
    LOCAL ALIGN1, ALIGN2, ALIGN2F, ALIGN3,ALIGN3F,RETURN
    MOV COUNTER, 1  ; Counter = 1
    MOV AX, D3      ; Check if D3 > 0, if yes jump to ALIGN2F, if not jump to ALIGN1
    CMP AX, 0
    JE ALIGN1       
    JNE ALIGN2F

    ALIGN1:
        MOV AX, COUNTER    ; Counter +=1
        ADD AX, 1
        MOV COUNTER, AX

        MOV BX, D2          ; D3 = D2, D2 = D1, D1 = D0, D0 = 0
        MOV D3, BX
        MOV CX, D1
        MOV D2, CX
        MOV CX, D0
        MOV D1, CX
        MOV D0, 0

        MOV AX, COUNTER     ; Check if Counter = 4, if yes jump to RETURN
        CMP AX, 4
        JE RETURN

        MOV BX, D3          ; Check if D3 = 0, If yes jump to ALIGN1, if not jump to ALIGN2F
        CMP BX, 0
        JE ALIGN1
        JNE ALIGN2F

    ALIGN2F:                ; First Initialization of ALIGN2
        MOV AX, COUNTER     ; Initialize Counter = 1
        MOV AX, 1
        MOV COUNTER, AX 
        JMP ALIGN2          ; Jump to ALIGN2
    ALIGN2:
        MOV AX, COUNTER     ; Counter += 1
        ADD AX, 1
        MOV COUNTER, AX

        MOV AX, D2          ; Check if D2 = 0, If not jump to ALIGN3
        CMP AX, 0
        JNE ALIGN3F

        MOV AX, D1          ; D2 = D1, D1 = D0, D0 = 0
        MOV BX, D0      
        MOV D2, AX
        MOV D1, BX
        MOV D0, 0
  
        MOV AX, COUNTER     ; Check if Counter = 3, Jump to RETURN 
        CMP AX, 3
        JE RETURN

        MOV AX, D2          ; Check if D2 = 0, If yes jump to ALIGN2, if not jump to ALIGN3F
        CMP AX, 0
        JE ALIGN2
        JNE ALIGN3F
    ALIGN3F:                ; First Initialize of ALIGN3F
        MOV AX, COUNTER     ; Initialize Counter = 1
        MOV AX, 1
        MOV COUNTER, AX 
        JMP ALIGN3    
    ALIGN3: 
        MOV AX, D1          ; Check if D1 = 0, If yes jump to Return
        CMP AX, 0
        JNE RETURN

        MOV AX, COUNTER     ; Counter += 1
        ADD AX, 1
        MOV COUNTER, AX

        MOV AX, COUNTER     
        CMP AX, 3           ; Check if Counter = 3, If yes jump to RETURN
        JE RETURN

        MOV AX, D0          ; D1 = D0, D0 = 0
        MOV D1, AX
        MOV D0, 0

        CMP AX, 0           ; Check if D1 = 0, If yes jump to ALIGN3, if not jump to RETURN
        JE ALIGN3
        JNE RETURN
        
    RETURN:               
ENDM
SCORING PROC NEAR   
    ADD BX, AX    
    MOV AX, 0    
    ADD CX, BX 
    RET  
SCORING ENDP

COMPARING MACRO D0, D1, D2, D3, SCORE               ; Compare Matriks
    LOCAL CHECK,FLAG1,FLAG2,FLAG3,CORRECT1, CORRECT2, CORRECT3, RETURN
    
    MOV F1, 0   ; SET COMPARE FLAG TO 0
    MOV F2, 0
    MOV F3, 0
    
    MOV CX, SCORE
    CHECK:          ; Check untuk flag yang inign dimasuki
    CMP F1, 0
    JE FLAG1
    CMP F2, 0
    JE FLAG2
    CMP F3, 0
    JE FLAG3
    JMP RETURN 

    FLAG1:          ; Perbandingan D3, D2
    MOV AL, 1
    MOV F1, AL
    MOV AX, D3
    MOV BX, D2
    CMP AX, BX 
    JE CORRECT1
    JMP CHECK
        
    FLAG2:          ; Perbandingan D2, D1
    MOV AL, 1
    MOV F2, AL
    MOV AX, D2
    MOV BX, D1
    CMP AX, BX        
    JE CORRECT2
    JMP CHECK
        
    FLAG3:          ; Perbandingan D1, D0
    MOV AL, 1
    MOV F3, AL
    MOV AX, D1
    MOV BX, D0
    CMP AX, BX        
    JE CORRECT3
    JMP CHECK 
     
    CORRECT1:        ; Score + swap D3, D2
    CALL SCORING
    MOV D3, BX
    MOV D2, AX

    JMP CHECK
    
    CORRECT2:        ; Score + swap D2, D1
    CALL SCORING    
    MOV D2, BX
    MOV D1, AX  
    JMP CHECK
    
    CORRECT3:        ; Score + swap D1, D0
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
SHIFT_ROW_RIGHT MACRO MAT, INDEX, SCORE     ; Geser kanan
    ; CLEAN TEMPORARY VARIABLE
    
    LEA SI, MAT 
    ADD SI, INDEX
    ADD SI, INDEX
    
    CALL GET_ROW_VALUE
    ALIGNMAT D0, D1, D2, D3, COUNTER    ; Align kanan
    COMPARING D0, D1, D2, D3, SCORE     ; Compare kanan
    ALIGNMAT D0, D1, D2, D3, COUNTER    ; Align lagi ke kanan

    LEA SI, MAT
    ADD SI, INDEX
    ADD SI, INDEX
                                        ; Masukkan ke matriks
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

SHIFT_ROW_LEFT MACRO MAT, INDEX, SCORE      ; Geser ke kiri
    ; CLEAN TEMPORARY VARIABLE

    LEA SI, MAT 
    ADD SI, INDEX
    ADD SI, INDEX
    
    CALL GET_ROW_VALUE
    ALIGNMAT D3, D2, D1, D0, COUNTER        ; Align kiri
    COMPARING D3, D2, D1, D0, SCORE         ; Compare kiri
    ALIGNMAT D3, D2, D1, D0, COUNTER        ; Align kiri
    

    LEA SI, MAT
    ADD SI, INDEX
    ADD SI, INDEX
                                        ; Masukkan ke matriks

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



SHIFT_COL_UP MACRO MAT, INDEX, SCORE    ; Geser atas
    ; CLEAN TEMPORARY VARIABLE

    LEA SI, MAT 
    ADD SI, INDEX
    ADD SI, INDEX
    
    CALL GET_COL_VALUE
    ALIGNMAT D3, D2, D1, D0, COUNTER    ; Align atas
    COMPARING D3, D2, D1, D0, SCORE     ; Compare atas
    ALIGNMAT D3, D2, D1, D0, COUNTER    ; Align atas
    LEA SI, MAT
    ADD SI, INDEX
    ADD SI, INDEX
                                            ; Masukkan ke matriks
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

SHIFT_COL_DOWN MACRO MAT, INDEX, SCORE      ; Geser bawah
    ; CLEAN TEMPORARY VARIABLE

    LEA SI, MAT 
    ADD SI, INDEX
    ADD SI, INDEX
    
    CALL GET_COL_VALUE
    ALIGNMAT D0, D1, D2, D3, COUNTER        ; Align bawah
    COMPARING D0, D1, D2, D3, SCORE         ; Compare bawah
    ALIGNMAT D0, D1, D2, D3, COUNTER        ; Align bawah
    
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

FINAL_CHECK_ROW MACRO MAT, INDEX        ; Check win condition per baris
    LOCAL WINFLAG, RET_CHECK
    LEA SI, MAT                  ; LOAD MAT ADDRESS
    ADD SI, INDEX                ; ADD MAT ADDRESS ACCORDING TO INDEX, 2 TIMES BECAUSE OF WORD SIZE
    ADD SI, INDEX                ; GET VALUE FOR D0, D1, D2, D3
    CALL GET_ROW_VALUE
    
    MOV CX, 2048H
    MOV DX, 0H
    ; Check kondisi, jika D0, D1, D2, D3 = 2048
    CMP CX, D0
    JE WINFLAG
    
    CMP CX, D1
    JE WINFLAG
    
    CMP CX, D2
    JE WINFLAG
    
    CMP CX, D3
    JE WINFLAG
    JMP RET_CHECK
    
    
    WINFLAG:    ; Set win = 1
    MOV WIN, 1
    
    RET_CHECK:
        
ENDM

FINAL_CHECK MACRO MAT           ; Check win condition
    FINAL_CHECK_ROW MAT, 00H
    FINAL_CHECK_ROW MAT, 04H
    FINAL_CHECK_ROW MAT, 08H
    FINAL_CHECK_ROW MAT, 0CH
    
ENDM
    
LOSE_CHECK_ROW MACRO MAT, INDEX
    LOCAL LOSEFLAG, LOSE2FLAG, RET_CHECK
    LEA SI, MAT                  ; LOAD MAT ADDRESS
    ADD SI, INDEX                ; ADD MAT ADDRESS ACCORDING TO INDEX, 2 TIMES BECAUSE OF WORD SIZE
    ADD SI, INDEX                ; GET VALUE FOR D0, D1, D2, D3
    CALL GET_ROW_VALUE
    
    MOV CX, 0H                  
    MOV DX, 0H
  
    CMP CX, D0      ; Check if D0 = 0, IF yes jump to LOSE2FLAG, If not jump to LOSEFLAG
    JNE LOSEFLAG
    JE LOSE2FLAG

    CMP CX, D1      ; Check if D1 = 0, If yes jump to LOSE2FLAG, if not jump to LOSEFLAG
    JNE LOSEFLAG
    JE LOSE2FLAG
    
    CMP CX, D2      ; Check if D2 = 0, If yes jump to LOSE2FLAG, if not jump to LOSEFLAG
    JNE LOSEFLAG
    JE LOSE2FLAG
    
    CMP CX, D3      ; Check if D3 = 0, If yes jump to LOSE2FLAG, if not jump to LOSEFLAG
    JNE LOSEFLAG
    JE LOSE2FLAG
    
    LOSEFLAG:       
    MOV LOSE, 1
    
    LOSE2FLAG:
    MOV LOSE, 0
    
    RET_CHECK:
        
ENDM   
LOSE_CHECK MACRO MAT        ; Check lose condition
    LOCAL LOSE_OUT, END_LOSE
    LOSE_CHECK_ROW MAT, 00H
    LOSE_CHECK_ROW MAT, 04H
    LOSE_CHECK_ROW MAT, 08H
    LOSE_CHECK_ROW MAT, 0CH
    
ENDM
    
;=======================================================================================================
.startup

MENU:
MOV SCORE, 0

SETCURSOR 2,10             ; Set default menu into start
PRINTLINE STRMENU1, 0AH    ; Print Menu
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
RANDOM_POPUP        ; Pop up
PLAY:   
RANDOM_POPUP        ; Pop up
PLAYFUNC MATRIX     ; Playfunc Matrix   

LOSE_CHECK MATRIX       ; Lose condition
FINAL_CHECK MATRIX      ; Win condition
CMP WIN, 0
JNE WIN_OUT
CMP LOSE, 0
JNE LOSE_OUT

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
SHIFT_COL_DOWN  MATRIX, 00H, SCORE          ; Memroses kolom 1
SHIFT_COL_DOWN  MATRIX, 01H, SCORE          ; Memroses kolom 2
SHIFT_COL_DOWN  MATRIX, 02H, SCORE          ; Memroses kolom 3
SHIFT_COL_DOWN  MATRIX, 03H, SCORE          ; Memroses kolom 4
JMP PLAY

ARROWUP:
SHIFT_COL_UP  MATRIX, 00H, SCORE            ; Memroses kolom 1
SHIFT_COL_UP  MATRIX, 01H, SCORE            ; Memroses kolom 2
SHIFT_COL_UP  MATRIX, 02H, SCORE            ; Memroses kolom 3
SHIFT_COL_UP  MATRIX, 03H, SCORE            ; Memroses kolom 4
JMP PLAY

ARROWRIGHT:
SHIFT_ROW_RIGHT MATRIX, 00H, SCORE          ; memroses baris 1
SHIFT_ROW_RIGHT MATRIX, 04H, SCORE          ; memroses baris 2
SHIFT_ROW_RIGHT MATRIX, 08H, SCORE          ; memroses baris 3
SHIFT_ROW_RIGHT MATRIX, 0CH, SCORE          ; memroses baris 4
JMP PLAY

ARROWLEFT:
SHIFT_ROW_LEFT MATRIX, 00H, SCORE           ; memroses baris 1
SHIFT_ROW_LEFT MATRIX, 04H, SCORE           ; memroses baris 2
SHIFT_ROW_LEFT MATRIX, 08H, SCORE           ; memroses baris 3
SHIFT_ROW_LEFT MATRIX, 0CH, SCORE           ; memroses baris 4
JMP PLAY

WIN_OUT:                                    ; winning condition check
    SETCURSOR 1, 10
    PRINTLINE STRWIN, 0AH    

LOSE_OUT:                                   ; losing condition check
    SETCURSOR 1, 10
    PRINTLINE STRLOSE, 0CH    

EXIT:
.exit
END
