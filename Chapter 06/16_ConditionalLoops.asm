; ============================================================
; 파일명  : 16_ConditionalLoops.asm
; 설  명  : 6장 조건 처리 (3) - 조건부 루프 명령어
;           LOOPZ / LOOPE / LOOPNZ / LOOPNE
;           (PDF 06_Conditional Processing - Conditional Loop Instructions)
; ============================================================
;
; [기본 LOOP 와의 차이]
;   LOOP   : ECX를 1 감소시키고 ECX != 0 이면 점프
;   LOOPZ/LOOPE   : ECX 감소 후 (ECX != 0) AND (ZF == 1) 이면 점프
;   LOOPNZ/LOOPNE : ECX 감소 후 (ECX != 0) AND (ZF == 0) 이면 점프
;
;   ★ ZF는 LOOPxx 명령 자체가 바꾸지 않음 → 직전 명령의 ZF를 본다
;   ★ LOOPZ = LOOPE,  LOOPNZ = LOOPNE (같은 opcode)
;
;   동작 순서 (LOOPZ/LOOPE)
;     ① ECX = ECX - 1
;     ② (ECX != 0) 그리고 (ZF = 1) 이면 → 레이블로 점프
;     ③ 아니면 → 다음 명령으로 진행 (루프 종료)
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    ; LOOPNZ 예제: 처음으로 음수가 아닌(0 이상) 수를 찾는 배열
    array    SWORD -3, -6, -1, -10, 10, 30, 40, 4
    sentinel SWORD 0

.CODE
main PROC

    ; ==========================================================
    ; LOOPNZ/LOOPNE 응용: 첫 번째 '음수가 아닌' 수 찾기
    ;
    ;   각 원소의 부호 비트(비트15)를 TEST로 검사한다.
    ;   · 음수면 부호 비트=1 → TEST 결과 ZF=0 → LOOPNZ 계속
    ;   · 0이상이면 부호 비트=0 → TEST 결과 ZF=1 → 루프 탈출
    ;
    ;   ★ 핵심: ADD가 ZF를 바꾸므로, TEST 직후의 플래그를
    ;     스택에 저장(PUSHFD)했다가 LOOPNZ 직전에 복원(POPFD)한다.
    ; ==========================================================

    mov esi, OFFSET array
    mov ecx, LENGTHOF array
L1:
    test WORD PTR [esi], 8000h   ; 부호 비트(비트15) 검사
    pushfd                       ; 플래그를 스택에 저장
    add  esi, TYPE array         ; 다음 원소로 이동(ZF가 변함)
    popfd                        ; 저장해 둔 플래그 복원
    loopnz L1                    ; ZF=0(음수)이고 ECX!=0이면 반복

    jnz quit                     ; 끝까지 음수만 있었음 → 종료
    sub esi, TYPE array          ; ESI를 찾은 값 위치로 되돌림
    ; 이 시점에서 [esi] = 첫 번째 0 이상인 값(=10)
quit:

    ; ==========================================================
    ; (참고) LOOPE/LOOPZ 동작 개념
    ;   "조건이 같은(equal) 동안 계속 반복"
    ;   예: 배열에서 연속된 동일 값이 이어지는 구간을 셀 때 등
    ;   동작: ECX 감소 후 ECX!=0 그리고 ZF=1 이면 점프
    ; ==========================================================

    INVOKE ExitProcess, 0
main ENDP

END main
