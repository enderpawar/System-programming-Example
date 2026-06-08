; ============================================================
; 시스템프로그래밍 기말고사 핵심 문제 코드
; 목적: 2023/2024 기출 + 2025 예상문제 반복 유형을 손으로 풀기
; 사용법: 주석의 [문제]를 먼저 풀고, 아래 [정답]을 가려서 확인
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    VAR1 SDWORD ?
    VAR2 SDWORD ?
    VAR3 SDWORD ?
    VAR4 SDWORD ?
    VAR5 SDWORD ?
    x    DWORD 1
    y    DWORD 2
    sum  DWORD 0
    datestamp WORD 266Ah
    Array BYTE 81 DUP(0)

.CODE

; ============================================================
; [문제 1] 조건부 점프 flag 조건을 쓰시오.
;
; JA  = __________________________
; JB  = __________________________
; JBE = __________________________
; JE  = __________________________
; JG  = __________________________
; JL  = __________________________
; JGE = __________________________
; JNE = __________________________
;
; [정답]
; JA  = CF=0 AND ZF=0
; JB  = CF=1
; JBE = CF=1 OR ZF=1
; JE  = ZF=1
; JG  = ZF=0 AND SF=OF
; JL  = SF!=OF
; JGE = SF=OF
; JNE = ZF=0

; ============================================================
; [문제 2] if ((VAR1 < VAR2) OR (VAR3 >= VAR4)) VAR5=1;
; 단, signed DWORD. 빈칸을 채우시오.
;     
;     mov eax, VAR1
;     cmp eax, VAR2
;     ______ L_TRUE
;     mov eax, VAR3
;     cmp eax, VAR4
;     ______ L_TRUE
;     jmp L_END
; L_TRUE:
;     mov VAR5, 1
; L_END:
;
; [정답]
Problem2 PROC
    mov eax, VAR1
    cmp eax, VAR2
    jl  P2_TRUE
    mov eax, VAR3
    cmp eax, VAR4
    jge P2_TRUE
    jmp P2_END
P2_TRUE:
    mov VAR5, 1
P2_END:
    ret
Problem2 ENDP

; ============================================================
; [문제 3] if ((VAR1 <= VAR2) AND (VAR3 != VAR4)) VAR5=1;
; else VAR5=0; signed DWORD로 작성하시오.
;
Problem3 PROC
    mov eax,var1
    cmp eax,VAR2
    jg P3_FALSE
    mov ebx,VAR3
    cmp ebx,VAR4
    je P3_FALSE
    mov var5,1
P3_FALSE: mov var5,0
; [정답]
Problem3 PROC
    mov eax, VAR1
    cmp eax, VAR2
    jg  P3_FALSE
    mov eax, VAR3
    cmp eax, VAR4
    je  P3_FALSE
    mov VAR5, 1
    jmp P3_END
P3_FALSE:
    mov VAR5, 0
P3_END:
    ret
Problem3 ENDP

; ============================================================
; [문제 4] eax = var * 72를 IMUL 없이 작성하시오.
; 72 = 64 + 8
;

PROBLEM4 PROC
mov eax,var

; [정답]
Problem4 PROC
    mov eax, VAR1
    mov ebx, eax
    shl eax, 6
    shl ebx, 3
    add eax, ebx
    ret
Problem4 ENDP

; ============================================================
; [문제 5] VAR4 = (-VAR1 * 5) / (VAR2 * VAR3)
; signed DWORD로 작성하시오.
;
; [정답]
Problem5 PROC
    mov eax, VAR2
    imul eax, VAR3
    mov ebx, eax

    mov eax, VAR1
    neg eax
    imul eax, 5
    cdq
    idiv ebx
    mov VAR4, eax
    ret
Problem5 ENDP

; ============================================================
; [문제 6] VAR4 = (4 * VAR1) % (VAR2 - VAR3)
; signed DWORD로 작성하시오.
;
; [정답]
Problem6 PROC
    mov eax, VAR1
    shl eax, 2
    mov ebx, VAR2
    sub ebx, VAR3
    cdq
    idiv ebx
    mov VAR4, edx
    ret
Problem6 ENDP

; ============================================================
; [문제 7] STDCALL swap(int *a, int *b)를 작성하시오.
; enter/leave 사용 금지.
;
; [정답]
swap PROC
    push ebp
    mov  ebp, esp
    sub  esp, 4
    push eax
    push ebx
    push edx

    mov  eax, [ebp+8]
    mov  ebx, [ebp+12]
    mov  edx, [eax]
    mov  [ebp-4], edx
    mov  edx, [ebx]
    mov  [eax], edx
    mov  edx, [ebp-4]
    mov  [ebx], edx

    pop  edx
    pop  ebx
    pop  eax
    mov  esp, ebp
    pop  ebp
    ret  8
swap ENDP

; ============================================================
; [문제 8] 위 swap을 STDCALL로 호출하시오. invoke 사용 금지.
;
; [정답]
Problem8 PROC
    push OFFSET y
    push OFFSET x
    call swap
    ret
Problem8 ENDP

; ============================================================
; [문제 9] 다음 .WHILE을 directive 없이 작성하시오.
;
; mov eax, 0
; .WHILE eax < 10
;     inc eax
;     add sum, eax
; .ENDW
;
; 단, eax와 10은 unsigned로 비교한다.
;
; [정답]
Problem9 PROC
    mov eax, 0
P9_L1:
    cmp eax, 10
    jae P9_L2
    inc eax
    add sum, eax
    jmp P9_L1
P9_L2:
    ret
Problem9 ENDP

; ============================================================
; [문제 10] 1단부터 9단까지 구구단 결과를 Array에 저장하시오.
; 핵심: 외부 loop의 ECX를 내부 loop에서 보존해야 한다.
;
; [정답]
Problem10 PROC
    mov bl, 0
    mov ecx, 9
    mov esi, 0
P10_OuterLoop:
    inc bl
    mov bh, 0
    push ecx
    mov ecx, 9
P10_InnerLoop:
    inc bh
    mov al, bl
    mul bh
    mov Array[esi], al
    inc esi
    loop P10_InnerLoop
    pop ecx
    loop P10_OuterLoop
    ret
Problem10 ENDP

; ============================================================
; [문제 11] datestamp WORD 266Ah에서 일/월/연도를 추출하시오.ㅇ
; bit 0~4 day, bit 5~8 month, bit 9~15 year offset from 1980.
;
; [정답]
Problem11 PROC
    mov ax, datestamp
    and ax, 0000000000011111b    ; day = 10

    mov ax, datestamp
    shr ax, 5
    and ax, 0000000000001111b    ; month = 3

    mov ax, datestamp
    shr ax, 9
    add ax, 1980                 ; year = 1999
    ret
Problem11 ENDP

; ============================================================
; [문제 12] 실행 결과를 쓰시오.
;
; mov eax, -1
; mov cl, 4
; sar eax, cl
; shl eax, 1
;
; [정답] EAX = FFFFFFFEh

; ============================================================
; [문제 13] 실행 결과를 쓰시오.
;
; mov ax, 00FFh
; mov bl, 10h
; div bl
;
; [정답] AL=0Fh, AH=0Fh. divide error 없음.

; ============================================================
; [문제 14] unsigned 64-bit 덧셈: EDX:EAX = FFFFFFFFh + FFFFFFFFh
;
; [정답]
Problem14 PROC
    mov edx, 0
    mov eax, 0FFFFFFFFh
    add eax, 0FFFFFFFFh
    adc edx, 0
    ret
Problem14 ENDP

main PROC
    INVOKE ExitProcess, 0
main ENDP

END main
