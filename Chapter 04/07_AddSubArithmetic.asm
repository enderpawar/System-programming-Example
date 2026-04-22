; ============================================================
; 파일명  : 07_AddSubArithmetic.asm
; 설  명  : 덧셈/뺄셈 명령어와 CPU 상태 플래그 예제
;           INC / DEC / ADD / SUB / NEG / 산술 표현식 구현 /
;           Carry / Zero / Sign / Overflow / Parity / Auxiliary Carry 플래그
;           (PDF 4장 - Addition and Subtraction)
; ============================================================
;
; [CPU 상태 플래그 요약]
;   CF (Carry Flag)         : 부호 없는 정수 오버플로 발생 시 1
;   OF (Overflow Flag)      : 부호 있는 정수 오버플로 발생 시 1
;   ZF (Zero Flag)          : 연산 결과가 0일 때 1
;   SF (Sign Flag)          : 연산 결과가 음수(MSB=1)일 때 1
;   PF (Parity Flag)        : 결과 하위 바이트의 1-비트 개수가 짝수일 때 1
;   AC (Auxiliary Carry)    : 비트 3에서 올림이 발생할 때 1
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    ; INC / DEC 예제용
    myByte  BYTE  0FFh          ; 초기값 255 (BYTE 최댓값)
    myWord  WORD  0             ; 초기값 0

    ; ADD / SUB 예제용
    val1    DWORD 10000h
    val2    DWORD 30000h
    result  DWORD 0

    ; NEG 예제용
    negVal  SDWORD -24

    ; 산술 표현식 구현용 (C++: rval = -Xval + (Yval - Zval))
    Xval    SDWORD 26
    Yval    SDWORD 30
    Zval    SDWORD 40
    rval    SDWORD 0

.CODE
main PROC

    ; ==========================================================
    ; INC 명령어 - 피연산자에 1을 더함 (Increment)
    ; DEC 명령어 - 피연산자에서 1을 뺌 (Decrement)
    ;
    ;   피연산자: 레지스터 또는 메모리 변수
    ;   영향 플래그: OF, ZF, SF, AC, PF (Carry 플래그는 영향 없음!)
    ;   주의: INC/DEC는 Carry 플래그를 바꾸지 않는 것이 특징
    ; ==========================================================

    ; 레지스터 INC/DEC
    mov eax, 5
    inc eax             ; EAX = 6
    dec eax             ; EAX = 5

    ; 메모리 변수 INC/DEC
    inc myByte          ; myByte: 0FFh -> 00h (오버플로, ZF=1, OF=1)
    dec myWord          ; myWord: 0000h -> FFFFh (언더플로, SF=1)

    ; ==========================================================
    ; ADD 명령어 - 소스를 목적지에 더함
    ;   형식: ADD 목적지, 소스
    ;   소스는 변경되지 않으며, 합계는 목적지에 저장
    ;   피연산자 규칙은 MOV와 동일
    ;   영향 플래그: CF, ZF, SF, OF, AC, PF
    ; ==========================================================

    ; 레지스터에 즉치 더하기
    mov eax, 1000h
    add eax, 2000h      ; EAX = 3000h

    ; 레지스터에 메모리 변수 더하기
    mov eax, val1       ; EAX = 10000h
    add eax, val2       ; EAX = 10000h + 30000h = 40000h
    mov result, eax     ; 결과를 메모리에 저장

    ; CF(Carry) 플래그 예시: 8비트 최댓값 + 1
    mov al, 0FFh        ; AL = 255 (BYTE 최댓값)
    add al, 1           ; AL = 0, CF = 1 (255+1 = 256, 8비트 초과)

    ; ZF(Zero) 플래그 예시: 같은 값 더하기 후 뺐을 때
    mov eax, 5
    add eax, 0          ; ZF = 0 (결과 5 != 0)
    sub eax, 5          ; EAX = 0, ZF = 1 (결과 == 0)

    ; ==========================================================
    ; SUB 명령어 - 목적지에서 소스를 뺌
    ;   형식: SUB 목적지, 소스
    ;   피연산자 규칙은 ADD/MOV와 동일
    ;   영향 플래그: CF, ZF, SF, OF, AC, PF
    ;
    ;   CF(Carry) 플래그 규칙:
    ;     큰 부호 없는 정수에서 작은 값을 빼면 CF = 0 (정상)
    ;     작은 부호 없는 정수에서 큰 값을 빼면 CF = 1 (언더플로)
    ; ==========================================================

    ; 기본 뺄셈
    mov eax, 100
    sub eax, 30         ; EAX = 70, CF=0 (정상)
    

    ; CF=1 예시: 작은 값에서 큰 값을 뺌
    mov al, 10
    sub al, 20          ; AL = -10 (246), CF = 1 (언더플로 발생)

    ; SF(Sign) 플래그 예시
    mov eax, 5
    sub eax, 10         ; EAX = -5, SF = 1 (결과가 음수, MSB=1)

    ; ==========================================================
    ; NEG 명령어 - 부호 반전 (Negate)
    ;   피연산자를 2의 보수로 변환 (부호를 뒤집음)
    ;   2의 보수: 모든 비트를 뒤집고 1을 더하는 방식
    ;   피연산자: 레지스터 또는 메모리 변수
    ;   영향 플래그: CF, ZF, SF, OF, AC, PF
    ;
    ;   주의: 0이 아닌 값에 NEG를 적용하면 항상 CF=1 이 됨
    ;         0에 NEG를 적용하면 CF=0, ZF=1
    ;
    ;   주의: 부호 있는 정수 범위 한계에서 오버플로 가능
    ;         예) SBYTE의 최솟값 -128에 NEG 적용 시 결과 = -128 (OF=1)
    ; ==========================================================

    ; 정수 부호 반전
    mov eax, -24
    neg eax             ; EAX = +24, CF=1

    mov eax, 24
    neg eax             ; EAX = -24, CF=1

    ; 메모리 변수 부호 반전
    neg negVal          ; negVal: -24 -> +24

    ; 0에 NEG 적용
    mov eax, 0
    neg eax             ; EAX = 0, CF=0, ZF=1

    ; ==========================================================
    ; 산술 표현식 구현 (Implementing Arithmetic Expressions)
    ;   C++ 표현식: rval = -Xval + (Yval - Zval)
    ;
    ;   Xval=26, Yval=30, Zval=40 이라면
    ;   rval = -26 + (30 - 40) = -26 + (-10) = -36
    ;
    ;   x86은 메모리-메모리 직접 연산 불가
    ;   -> 각 항을 레지스터에 옮겨서 계산
    ; ==========================================================

    ; 항 1: -Xval  -> EAX에 계산
    mov eax, Xval       ; EAX = 26
    neg eax             ; EAX = -26

    ; 항 2: (Yval - Zval) -> EBX에 계산
    mov ebx, Yval       ; EBX = 30
    sub ebx, Zval       ; EBX = 30 - 40 = -10

    ; 두 항 합산
    add eax, ebx        ; EAX = -26 + (-10) = -36

    ; 결과를 메모리 변수에 저장
    mov rval, eax       ; rval = -36

    ; ==========================================================
    ; 플래그 관찰 예시 (Flags Overview)
    ; ==========================================================

    ; PF(Parity) 플래그 예시
    ;   결과 하위 바이트에서 1인 비트 개수가 짝수이면 PF=1
    mov al, 0           ; AL = 0000_0000b  -> 1의 개수: 0개(짝수) PF=1
    mov al, 10000101b   ; AL = 1000_0101b  -> 1의 개수: 3개(홀수) PF=0
    add al, 0           ; 0을 더해 AL 값은 유지, PF 갱신

    ; OF(Overflow) 플래그 예시
    ;   부호 있는 정수의 오버플로 (양수+양수=음수가 되면 오버플로)
    mov al, 127         ; AL = 01111111b (SBYTE 최댓값 +127)
    add al, 1           ; AL = 10000000b = -128, OF=1 (오버플로!)

    ;   언더플로 (음수+음수=양수가 되면 오버플로)
    mov al, -128        ; AL = 10000000b (SBYTE 최솟값 -128)
    sub al, 1           ; AL = 01111111b = +127, OF=1 (언더플로!)

    ;   부호가 다른 두 수를 더할 때는 오버플로 발생 안 함
    mov al, 50
    add al, -30         ; OF=0 (부호가 다른 두 수의 합)

    INVOKE ExitProcess, 0
main ENDP

END main
