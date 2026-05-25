; ============================================================
; [시험 대비 빈칸 채우기] 5장 - 프로시저 정의 / CALL / RET / USES
; 빈칸( ______ )을 채우세요. 정답은 파일 최하단 주석 참고.
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    intArray  DWORD  10, 20, 30, 40, 50
    theSum    DWORD  ?

.CODE

; ──────────────────────────────────────────────────────────
; [문제 1] 프로시저 구조 — 빈칸을 채우세요.
;
;   MyProc  (1)______ ; PROC
;       ...
;       (2)______ ;ret 
;   MyProc  (3)______ ;  ENDP 
; ──────────────────────────────────────────────────────────

; [문제 2] CALL / RET 동작 — 빈칸을 채우세요.
;
;   CALL MySub 실행 시:
;   ① (4)______ 를 스택에 PUSH ; 복귀주소   
;   ② 피호출 프로시저의 시작 주소를 (5)______ 에 복사 EIP 
;
;   RET 실행 시: 
;   ① 스택에서 (6)______ 를 POP → (5)______ 에 저장 ; 복귀주소 POP 
;   ② (7)______ 부터 실행 재개 

; ──────────────────────────────────────────────────────────
; [문제 3] SumOfThree — 코드를 완성하세요.
;   Receives: EAX, EBX, ECX
;   Returns : EAX = EAX + EBX + ECX

SumOfThree PROC
    (8)______ eax, ebx ; ADD  
    (9)______ eax, ecx ; ADD 
    (10)______ ; RET eax
SumOfThree ENDP

; ──────────────────────────────────────────────────────────
; [문제 4] ArraySum — 빈칸을 채우세요.
;   Receives: ESI = 배열 시작 오프셋, ECX = 원소 개수
;   Returns : EAX = 합계

ArraySum PROC
    (11)______ esi  ;push  
    (12)______ ecx  ;push 

    mov eax, 0 

sumL:
    add eax, (13)______  ;  arr[esi]
    add esi, (14)______  ;  TYPE arr 
    (15)______ sumL  loop  

    (16)______ ecx  ;pop 
    (17)______ esi  ;pop
    ret
ArraySum ENDP

; ──────────────────────────────────────────────────────────
; [문제 5] USES 연산자 — 빈칸을 채우세요.
;
;   USES 는 프로시저 (18)______ 시 자동 PUSH, ;호출
;   (19)______ 시 자동 POP 코드를 삽입 ; 반환 
;
;   절대 하면 안 되는 실수:
;   BadProc PROC USES (20)______ eax 
;       mov eax, 42
;       ret
;   BadProc ENDP
;   → 문제점: (21)______
;
;   해결: 반환값 레지스터는 USES 목록에서 (22)______

ArraySumUSES PROC USES esi ecx
    mov eax, 0
sumLU:
    add eax, [esi]
    add esi, 4
    loop sumLU
    ret
ArraySumUSES ENDP

; ──────────────────────────────────────────────────────────
; [문제 6] 중첩 호출 (Nested Calls) — 빈칸을 채우세요.
;
;   Sub2 PROC
;       mov ecx, 10
;       ret     ; (23)______ 으로 복귀 
;   Sub2 ENDP
;
;   Sub1 PROC
;       push eax
;       call (24)______ 
;       pop eax
;       ret     ; (25)______ 으로 복귀
;   Sub1 ENDP
;
;   CALL 마다 (26)______ 가 스택에 쌓이고  
;   RET 마다 (27)______ 으로 꺼냄 

; ──────────────────────────────────────────────────────────
; [문제 7] 전역 레이블 (Global Label) — 빈칸을 채우세요.
;
;   기본 레이블: 선언된 프로시저 (28)______ 에서만 유효
;   전역 레이블: 이름 뒤에 (29)______ 를 붙임
;
;   예)  TargetLabel(30)______

Sub2 PROC
    mov ecx, 10
    ret
Sub2 ENDP

Sub1 PROC
    push eax
    call Sub2
    pop  eax
    ret
Sub1 ENDP

main PROC
    mov eax, 10
    mov ebx, 20
    mov ecx, 30
    call SumOfThree

    mov esi, OFFSET intArray
    mov ecx, LENGTHOF intArray
    call ArraySum
    mov theSum, eax

    call Sub1

    INVOKE ExitProcess, 0
main ENDP
END main

; ============================================================
; ★ 정답 ★
; ============================================================
;
; (1)  PROC
; (2)  ret
; (3)  ENDP
;
; (4)  복귀 주소 (CALL 다음 명령어의 주소)
; (5)  EIP
; (6)  복귀 주소
; (7)  호출 이후 명령어
;
; (8)  add
; (9)  add
; (10) ret
;
; (11) push
; (12) push
; (13) [esi]
; (14) 4
; (15) loop
; (16) pop
; (17) pop
;
; (18) 시작 (진입)
; (19) 종료 (ret 직전)
; (20) eax
; (21) USES가 pop eax를 삽입하여 반환값이 원래 값으로 덮어써짐
; (22) 제거
;
; (23) Sub1
; (24) Sub2
; (25) main
; (26) 복귀 주소
; (27) 역순 (LIFO)
;
; (28) 내부
; (29) ::  (콜론 두 개)
; (30) ::
