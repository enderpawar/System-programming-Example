; ============================================================
; [시험 대비 빈칸 채우기] 5장 - 런타임 스택 / PUSH / POP
; 빈칸( ______ )을 채우세요. 정답은 E5_01_Stack_Answer.asm 참고.
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    myStr     BYTE  "ABCDE", 0
    strLen    = 5
    savedEAX  DWORD 0

.CODE
main PROC

; ──────────────────────────────────────────────────────────
; [문제 1] 스택 기본 개념 — 빈칸을 채우세요.
;
;   · 스택은 (1)______ 구조 ; FIFO
;   · 스택은 (2)______ 주소 → (3)______ 주소 방향으로 성장 ; 높은 -> 낮은
;   · (4)______ 레지스터가 스택의 최상단을 가리킴 ;ESP
;
;   PUSH 동작 (32비트 기준):
;   ① ESP (5)______= 4 ; +
;   ② [(6)______] = 값 ;esp 그러니까, [esp] 이런식으로 작성하면 값을 반환하는거지
;
;   POP 동작 (32비트 기준):
;   ① 목적지 = [(7)______] ; 
;   ② ESP (8)______= 4 [-]
;   ③ POP은 메모리를 (9) 지운다 / 지우지 않는다.
; ──────────────────────────────────────────────────────────

; [문제 2] PUSH/POP 결과 예측 — 최종값을 채우세요.
;
;   push 10
;   push 20
;   push 30
;   pop  eax     ; EAX = (10)______ ; 30
;   pop  ebx     ; EBX = (11)______ ; 20
;   pop  ecx     ; ECX = (12)______ ; 10
;
;   아래 코드의 문제점은?
;   push eax
;   push ebx
;   pop  eax     ; EAX = (13)______
;   pop  ebx     ; EBX = (14)______

; ──────────────────────────────────────────────────────────
; [문제 3] PUSH/POP 을 이용한 레지스터 보존 패턴
;
;   (15)______ eax 
;   (16)______ ebx
;
;   mov eax, 9999
;   mov ebx, 8888
;
;   (17)______ ebx
;   (18)______ eax
;
;   ★ POP 순서는 PUSH 순서의 (19)______ 여야 한다. ; 반대, 이렇게 안하면 꼬인대

; ──────────────────────────────────────────────────────────
; [문제 4] PUSHFD / POPFD
;
;   · PUSHFD : (20)______ → 스택 ;EFLAGS
;   · POPFD  : 스택 → (20)______ ; EFLAGS 
;   · MOV 명령어로는 EFLAGS를 (21) 읽을 수 있다 / 읽을 수 없다. ; 없다. 
;
;   EFLAGS 보존 패턴:
;   (22)______
;       ...
;   (23)______

; ──────────────────────────────────────────────────────────
; [문제 5] PUSHAD / POPAD
;
;   · PUSHAD : (24)______ 개의 32비트 범용 레지스터를 스택에 저장 ; 8개
;   · POPAD  : 역순으로 복원
;
;   · 반환값을 EAX로 돌려줄 때 POPAD를 사용하면 안 되는 이유:
;     (25)______ ; POPAD가 EAX를 덮어써서 반환값이 사라짐 
;
;   · 16비트 버전: (26)______ / (27)______

; ──────────────────────────────────────────────────────────
; [문제 6] 스택 활용 4가지 용도
;
;   ① (28)______ 임시 보존 ; 레지스터 
;   ② CALL 명령어의 (29)______ 저장 ; 복귀주소 
;   ③ 프로시저에 (30)______ 전달 ; 인수,인자 
;   ④ 프로시저 내 (31)______ 저장 ;지역변수 

; ──────────────────────────────────────────────────────────
; [문제 7] 스택으로 문자열 뒤집기 — 코드 완성
;          "ABCDE" → "EDCBA"
;
;   mov ecx, strLen
;   mov esi, 0
;
;   pushLoop:
;       (32)______ eax, myStr[esi] ;movzx  
;       (33)______ eax ; push 
;       inc esi
;       loop pushLoop
;
;   mov ecx, strLen
;   mov esi, 0
;
;   popLoop:
;       (34)______ eax ; pop  
;       mov myStr[esi], (35)______ ; al 
;       inc esi
;       loop popLoop
;   ; 결과: myStr = "(36)______" ; EDCBA 

    push 10h
    push 20h
    push 30h
    pop  eax
    pop  ebx
    pop  ecx

    mov ecx, strLen
    mov esi, 0
pushLoop:
    movzx eax, myStr[esi]
    push  eax
    inc   esi
    loop  pushLoop

    mov ecx, strLen
    mov esi, 0
popLoop:
    pop   eax
    mov   myStr[esi], al
    inc   esi
    loop  popLoop

    INVOKE ExitProcess, 0
main ENDP
END main
