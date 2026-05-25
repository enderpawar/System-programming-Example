; ============================================================
; 파일명  : 17_ConditionalStructures.asm
; 설  명  : 6장 조건 처리 (4) - 조건 구조 & 제어 흐름 디렉티브
;           IF / IF-ELSE / 복합 조건(AND,OR) / WHILE 루프 /
;           .IF .ELSE .ELSEIF .ENDIF / .WHILE / .REPEAT
;           (PDF 06_Conditional Processing - Conditional Structures /
;            Conditional Control Flow Directives)
; ============================================================
;
; [고수준 구조 → 어셈블리 변환의 핵심]
;   1) 불리언 식을 평가하여 CPU 플래그를 변경 (CMP 등)
;   2) 조건부 점프로 분기를 구현
;   ※ 변수끼리는 직접 비교 불가 → 한쪽을 레지스터로 옮긴 뒤 CMP
;   ※ 흔한 기법: 조건을 '반대로 뒤집어' ELSE/endwhile 로 점프
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    op1     DWORD 5
    op2     DWORD 10
    X       DWORD 0
    Y       DWORD 0
    val1    SDWORD 7
    val2    SDWORD 9

    ; 배열 합산 예제 (sample 보다 큰 원소들의 합)
    intarray DWORD 10, 60, 20, 33, 72, 89, 45, 65, 72, 18
    sample   DWORD 50
    sum      DWORD 0

.CODE
main PROC

    ; ==========================================================
    ; 1. 블록 구조 IF 문
    ;    if (op1 == op2)  X = 1;
    ;    else             X = 2;
    ;
    ;    기법: 조건을 반대로(JNE) 뒤집어 ELSE로 점프
    ; ==========================================================
    mov eax, op1
    cmp eax, op2           ; op1 == op2 ?
    jne L1                 ; 다르면 ELSE(L1)로
    mov X, 1               ; (then) X = 1
    jmp L2
L1: mov X, 2               ; (else) X = 2
L2:

    ; ==========================================================
    ; 2. 복합 조건 - 논리 AND (단축 평가 Short-Circuit)
    ;    if (al > 10 AND al < 20)  X = 1;
    ;    → 첫 조건이 거짓이면 둘째 조건은 평가하지 않음
    ;    기법: 첫 비교를 JBE(반대)로 뒤집어 거짓 시 바로 next
    ; ==========================================================
    mov al, 15
    cmp al, 10
    jbe next1              ; al <= 10 이면 거짓 → 건너뜀
    cmp al, 20
    jae next1              ; al >= 20 이면 거짓 → 건너뜀
    mov X, 1               ; 두 조건 모두 참
next1:

    ; ==========================================================
    ; 3. 복합 조건 - 논리 OR
    ;    if (al > 10 OR al == 0)  Y = 1;
    ;    → 첫 조건이 참이면 둘째는 평가 불필요 → 바로 분기
    ; ==========================================================
    mov al, 5
    cmp al, 10
    ja  L3                 ; al > 10 이면 참 → 실행부로
    cmp al, 0
    jne next2             ; 둘 다 거짓 → 건너뜀
L3: mov Y, 1               ; 둘 중 하나라도 참
next2:

    ; ==========================================================
    ; 4. WHILE 루프
    ;    while (val1 < val2)  val1++;
    ;    기법: 조건을 반대로(JNL) 뒤집어 endwhile로 점프
    ;          변수는 레지스터(EAX)로 옮겨 처리 (부호 있는 → JNL)
    ; ==========================================================
    mov eax, val1          ; EAX가 루프 안에서 val1 대역
beginwhile:
    cmp eax, val2          ; val1 < val2 ?
    jnl endwhile           ; val1 >= val2 이면 종료(부호 있음)
    inc eax                ; val1++
    jmp beginwhile
endwhile:
    mov val1, eax          ; 변수 값 복원

    ; ==========================================================
    ; 5. 루프 안에 IF 문 (배열 합산 응용)
    ;    sample(50) 보다 큰 모든 원소의 합을 구한다.
    ;    EDX=sample, EAX=sum, ESI=index, ECX=원소수
    ; ==========================================================
    mov eax, 0                     ; sum = 0
    mov edx, sample                ; EDX = 비교 기준값
    mov esi, 0                     ; 인덱스 = 0
    mov ecx, LENGTHOF intarray     ; 카운터
L4:
    cmp intarray[esi*4], edx       ; 원소 > sample ?
    jng L5                         ; 크지 않으면 건너뜀(부호 있음)
    add eax, intarray[esi*4]       ; 합에 누적
L5:
    inc esi
    loop L4
    mov sum, eax                   ; sum 저장

    ; ==========================================================
    ; 6. 고수준 제어 흐름 디렉티브 (.IF / .ELSEIF / .ENDIF)
    ;    MASM이 내부적으로 CMP + 조건부 점프를 자동 생성
    ;    조건식에 C 스타일 연산자 사용: < > == != && ||
    ; ==========================================================
    mov eax, op1
    .IF eax > op2
        mov X, 1
    .ELSEIF eax == op2
        mov X, 2
    .ELSE
        mov X, 3
    .ENDIF

    ; ==========================================================
    ; 7. .WHILE 디렉티브 (조건 먼저 검사)
    ;    값 1~10 을 ECX 로 세는 예
    ; ==========================================================
    mov eax, 0
    .WHILE eax < 10
        inc eax
    .ENDW

    ; ==========================================================
    ; 8. .REPEAT 디렉티브 (몸체 먼저 실행, .UNTIL 에서 검사)
    ; ==========================================================
    mov eax, 0
    .REPEAT
        inc eax
    .UNTIL eax == 10

    INVOKE ExitProcess, 0
main ENDP

END main
