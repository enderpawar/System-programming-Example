; ============================================================
; 시스템프로그래밍 기말고사 추가 문제 세트
; 범위: 6장 조건 처리, 7장 정수 산술, 8장 고급 프로시저, 9장 메모리 관리
; 사용법: [문제]를 먼저 손으로 풀고, 바로 아래 [정답]으로 확인
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    A       SDWORD 15
    B       SDWORD -7
    C       SDWORD 3
    D       SDWORD 0
    X       DWORD  12
    Y       DWORD  20
    Z       DWORD  0
    Count   DWORD  0
    Buffer  BYTE   10 DUP(?)
    Table   DWORD  16 DUP(0)
    Date2   WORD   4A21h
    p1      DWORD  OFFSET X
    p2      DWORD  OFFSET Y

.CODE

; ============================================================
; [추가 문제 1] signed 조건문을 MASM으로 작성하시오.
; if (A > B && C <= A) D = 1; else D = 0;
;
; [정답]
Extra01 PROC
    mov eax, A
    cmp eax, B
    jle E01_FALSE
    mov eax, C
    cmp eax, A
    jg  E01_FALSE
    mov D, 1
    jmp E01_END
E01_FALSE:
    mov D, 0
E01_END:
    ret
Extra01 ENDP

; ============================================================
; [추가 문제 2] unsigned 조건문을 MASM으로 작성하시오.
; if (X < Y || Z == 0) Count++;
;
; [정답]
Extra02 PROC
    mov eax, X
    cmp eax, Y
    jb  E02_TRUE
    cmp Z, 0
    je  E02_TRUE
    jmp E02_END
E02_TRUE:
    inc Count
E02_END:
    ret
Extra02 ENDP

; ============================================================
; [추가 문제 3] 조건부 점프를 고르시오.
; cmp eax, ebx 뒤에 signed eax >= ebx 이면 점프: ______
; cmp eax, ebx 뒤에 unsigned eax <= ebx 이면 점프: ______
; cmp eax, ebx 뒤에 eax != ebx 이면 점프: ______
;
; [정답] JGE, JBE, JNE

; ============================================================
; [추가 문제 4] 다음 실행 결과를 쓰시오.
; mov al, 11110000b
; test al, 00001111b
; ; ZF=?, AL=?
;
; [정답] ZF=1, AL=11110000b. TEST는 결과를 저장하지 않는다.

; ============================================================
; [추가 문제 5] 다음 실행 결과를 쓰시오.
; mov al, 80h
; cmp al, 7Fh
; ; unsigned 관점: AL > 7Fh 인가?
; ; signed 관점: AL > 7Fh 인가?
;
; [정답] unsigned는 참, signed는 거짓. 80h는 signed 8-bit에서 -128.

; ============================================================
; [추가 문제 6] IMUL 없이 eax = X * 45를 작성하시오.
; 45 = 32 + 8 + 4 + 1
;
; [정답]
Extra06 PROC
    mov eax, X
    mov ebx, eax
    mov ecx, eax
    mov edx, eax
    shl eax, 5
    shl ebx, 3
    shl ecx, 2
    add eax, ebx
    add eax, ecx
    add eax, edx
    ret
Extra06 ENDP

; ============================================================
; [추가 문제 7] signed 식을 작성하시오.
; D = (A - B) / C
;
; [정답]
Extra07 PROC
    mov eax, A
    sub eax, B
    cdq
    idiv C
    mov D, eax
    ret
Extra07 ENDP

; ============================================================
; [추가 문제 8] signed 나머지를 구하시오.
; D = (A + B * 2) % C
;
; [정답]
Extra08 PROC
    mov eax, B
    shl eax, 1
    add eax, A
    cdq
    idiv C
    mov D, edx
    ret
Extra08 ENDP

; ============================================================
; [추가 문제 9] 다음 실행 결과를 쓰시오.
; mov eax, -17
; cdq
; mov ebx, 5
; idiv ebx
; ; EAX=?, EDX=?
;
; [정답] EAX=-3, EDX=-2. IDIV의 나머지 부호는 피제수와 같다.

; ============================================================
; [추가 문제 10] 다음 코드가 divide error를 낼 수 있는 이유를 쓰시오.
; mov eax, 100
; mov edx, 1
; mov ebx, 10
; div ebx
;
; [정답] 32비트 DIV의 피제수는 EDX:EAX이다. EDX를 0으로 지우지 않아
; 실제 피제수가 00000001_00000064h가 되므로 몫이 EAX에 안 들어갈 수 있다.

; ============================================================
; [추가 문제 11] 64비트 unsigned 덧셈을 작성하시오.
; (EDX:EAX) = (EDX:EAX) + (ECX:EBX)
;
; [정답]
Extra11 PROC
    add eax, ebx
    adc edx, ecx
    ret
Extra11 ENDP

; ============================================================
; [추가 문제 12] 64비트 unsigned 뺄셈을 작성하시오.
; (EDX:EAX) = (EDX:EAX) - (ECX:EBX)
;
; [정답]
Extra12 PROC
    sub eax, ebx
    sbb edx, ecx
    ret
Extra12 ENDP

; ============================================================
; [추가 문제 13] LOOPNE 실행 조건을 쓰시오.
;
; [정답] ECX를 1 감소시킨 뒤, ECX != 0 이고 ZF = 0이면 점프한다.
; LOOPNE 자체는 ZF를 변경하지 않는다.

; ============================================================
; [추가 문제 14] .WHILE을 directive 없이 작성하시오.
; mov ecx, 0
; .WHILE ecx <= 5
;     inc Count
;     inc ecx
; .ENDW
; 단, unsigned 비교.
;
; [정답]
Extra14 PROC
    mov ecx, 0
E14_LOOP:
    cmp ecx, 5
    ja  E14_END
    inc Count
    inc ecx
    jmp E14_LOOP
E14_END:
    ret
Extra14 ENDP

; ============================================================
; [추가 문제 15] STDCALL 프로시저 AddTwo(int a, int b)를 작성하시오.
; 반환값은 EAX, callee가 stack을 정리한다.
;
; [정답]
AddTwo PROC
    push ebp
    mov  ebp, esp
    mov  eax, [ebp+8]
    add  eax, [ebp+12]
    pop  ebp
    ret  8
AddTwo ENDP

; ============================================================
; [추가 문제 16] AddTwo(12, 20)을 invoke 없이 호출하시오.
;
; [정답]
Extra16 PROC
    push 20
    push 12
    call AddTwo
    ret
Extra16 ENDP

; ============================================================
; [추가 문제 17] C calling convention과 STDCALL의 핵심 차이를 쓰시오.
;
; [정답]
; C convention: caller가 stack 정리. 여러 개의 인수를 받는 가변 인자 함수에 적합.
; STDCALL: callee가 ret n으로 stack 정리. Win32 API에서 자주 사용.

; ============================================================
; [추가 문제 18] 배열 주소를 매개변수로 받는 프로시저의 EBP 접근을 쓰시오.
; push LENGTHOF Buffer
; push OFFSET Buffer
; call Fill
;
; Fill PROC 내부에서 buffer 주소와 count는 각각 어디에 있는가?
;
; [정답] buffer 주소 = [ebp+8], count = [ebp+12]

; ============================================================
; [추가 문제 19] Date2 WORD 4A21h에서 day/month/year를 추출하시오.
; bit 0-4 day, bit 5-8 month, bit 9-15 year offset from 1980.
;
; [정답]
Extra19 PROC
    mov ax, Date2
    and ax, 0000000000011111b    ; day = 1

    mov ax, Date2
    shr ax, 5
    and ax, 0000000000001111b    ; month = 1

    mov ax, Date2
    shr ax, 9
    add ax, 1980                 ; year = 2017
    ret
Extra19 ENDP

; ============================================================
; [추가 문제 20] 메모리 관리 참거짓.
; 1) HeapAlloc이 실패하면 보통 NULL(0)을 반환한다.
; 2) HeapFree 후 같은 포인터를 계속 사용해도 안전하다.
; 3) page fault는 요청한 페이지가 메모리에 없을 때 발생할 수 있다.
; 4) 32-bit linear address의 하위 12비트는 page offset이다.
;
; [정답] 1) 참  2) 거짓  3) 참  4) 참

main PROC
    INVOKE ExitProcess, 0
main ENDP

END main
