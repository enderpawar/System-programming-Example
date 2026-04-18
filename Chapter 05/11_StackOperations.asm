; ============================================================
; 파일명  : 11_StackOperations.asm
; 설  명  : 런타임 스택 동작 원리와 PUSH / POP 명령어 예제
;           - Runtime Stack (32-bit mode)
;           - PUSH / POP
;           - PUSHFD / POPFD  (EFLAGS 저장/복원)
;           - PUSHAD / POPAD  (범용 레지스터 전체 저장/복원)
;           - 응용 예제: 스택으로 문자열 뒤집기
;           (PDF 5장 - Stack Operations)
; ============================================================
;
; ┌──────────────────────────────────────────────────────────┐
; │              [런타임 스택 핵심 개념 요약]                │
; │                                                          │
; │  · ESP (Extended Stack Pointer)                         │
; │    - 스택의 최상단(top) 주소를 가리키는 레지스터        │
; │    - 항상 마지막으로 PUSH된 값을 가리킴                  │
; │                                                          │
; │  · 스택은 "높은 주소 → 낮은 주소" 방향으로 성장         │
; │    (top이 아래쪽, bottom이 위쪽)                        │
; │                                                          │
; │  · PUSH: ESP -= 4, 값 기록  (스택이 아래로 자람)        │
; │  · POP : 값 읽기, ESP += 4  (스택이 위로 줄어듦)        │
; │                                                          │
; │  · LIFO (Last-In First-Out)                             │
; │    - 마지막에 넣은 값이 가장 먼저 꺼내짐                 │
; └──────────────────────────────────────────────────────────┘

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    ; --- 문자열 뒤집기 예제용 ---
    myStr   BYTE "ABCDE", 0          ; 뒤집을 문자열 (널 종료)
    strLen  = 5                      ; 문자열 길이 (상수)

    ; --- PUSHFD 예제용 ---
    savedFlags  DWORD 0              ; EFLAGS 값을 저장할 변수

.CODE
main PROC

    ; ==========================================================
    ; 1. PUSH 명령어
    ;    · 형식 : PUSH r/m16  /  PUSH r/m32  /  PUSH imm32
    ;    · 동작 : ESP -= (피연산자 크기)  →  [ESP] = 값
    ;    · 16비트 피연산자 → ESP -= 2
    ;    · 32비트 피연산자 → ESP -= 4
    ; ==========================================================

    push  10h           ; 스택에 0x10 삽입 (ESP -= 4, [ESP] = 10h)
    push  20h           ; 스택에 0x20 삽입 (ESP -= 4, [ESP] = 20h)
    push  30h           ; 스택에 0x30 삽입 (ESP -= 4, [ESP] = 30h)
    ; 현재 스택 상태 (주소 감소 방향 ↓)
    ;   [ESP]     = 30h  ← 최상단(top)
    ;   [ESP+4]   = 20h
    ;   [ESP+8]   = 10h

    ; ==========================================================
    ; 2. POP 명령어
    ;    · 형식 : POP r/m16  /  POP r/m32
    ;    · 동작 : 목적지 = [ESP]  →  ESP += (피연산자 크기)
    ;    · POP은 메모리를 지우지 않고 ESP만 올림
    ;      (ESP 아래 메모리는 "논리적으로 비어 있음"으로 간주)
    ; ==========================================================

    pop   eax           ; EAX = 30h, ESP += 4
    pop   ebx           ; EBX = 20h, ESP += 4
    pop   ecx           ; ECX = 10h, ESP += 4
    ; 스택이 PUSH 이전 상태로 복원됨

    ; ==========================================================
    ; 3. PUSH / POP을 이용한 레지스터 값 보존
    ;    · 프로시저 내부에서 레지스터를 수정하기 전에 PUSH,
    ;      수정이 끝나면 POP으로 원상복구하는 패턴
    ;    · 단, 반환값으로 쓰는 레지스터(보통 EAX)는 보존 금지!
    ; ==========================================================

    mov   eax, 100      ; 호출자(caller)가 사용 중인 EAX 값

    ; 서브루틴 진입 전 보존
    push  eax           ; EAX = 100 → 스택에 저장
    push  ebx           ; EBX 보존

    ; --- 이 사이에서 EAX, EBX를 마음대로 사용 ---
    mov   eax, 9999
    mov   ebx, 8888

    ; 서브루틴 종료 시 복원 (PUSH와 반대 순서로 POP!)
    pop   ebx           ; EBX 복원
    pop   eax           ; EAX = 100 복원
    ; eax 다시 100이 됨

    ; ==========================================================
    ; 4. PUSHFD / POPFD  — EFLAGS 레지스터 저장·복원
    ;    · PUSHFD : EFLAGS(32비트) 전체를 스택에 저장
    ;    · POPFD  : 스택에서 EFLAGS로 복원
    ;
    ;    주의: MOV로는 EFLAGS를 직접 읽거나 쓸 수 없으므로
    ;          반드시 PUSHFD / POPFD 를 사용해야 함
    ;
    ;    패턴 A: 코드 블록 전후로 플래그 보호
    ;       pushfd
    ;         ... (플래그를 변경하는 작업) ...
    ;       popfd
    ;
    ;    패턴 B: 플래그를 변수에 저장 (나중에 확인)
    ;       pushfd
    ;       pop  savedFlags    ; 스택 → 변수
    ;       ...
    ;       push savedFlags    ; 변수 → 스택
    ;       popfd
    ; ==========================================================

    ; 패턴 A: 블록 보호
    pushfd                   ; EFLAGS → 스택
    mov   eax, 0FFh          ; 0FFh -> 8비트로 표현할 수 있는 가장 큰 양수 값
    add   eax, 1             ; CF, OF 등 플래그 변경됨 -> 이건 클로드가 잘못쓴거임 eax가 아니라 al(1바이트정도로 선언해야 OF 일어남)
    popfd                    ; 원래 EFLAGS 복원

    ; 패턴 B: 변수 저장 후 복원
    pushfd
    pop   savedFlags         ; 변수에 EFLAGS 저장
    ; ... (다른 작업) ...
    push  savedFlags         ; 변수 → 스택
    popfd                    ; EFLAGS 복원

    ; ==========================================================
    ; 5. PUSHAD / POPAD  — 32비트 범용 레지스터 전체 저장·복원
    ;    · PUSHAD : EAX, ECX, EDX, EBX, ESP*, EBP, ESI, EDI 순서로 PUSH
    ;               (* ESP는 PUSHAD 실행 전 값이 저장됨)
    ;    · POPAD  : 위 순서의 역순으로 POP
    ;
    ;    · 16비트 버전: PUSHA / POPA (16비트 모드 전용)
    ;
    ;    주의: 반환값을 EAX로 돌려주는 프로시저에서는 POPAD를
    ;          사용하면 안 됨 → POPAD가 EAX를 덮어쓰기 때문!
    ; ==========================================================

    ; 프로시저 진입 시 모든 레지스터 저장
    pushad                   ; 8개 범용 레지스터 → 스택 (한 번에)

    ; --- EAX, EBX, ECX, EDX, ESI, EDI, EBP 를 마음대로 사용 ---
    mov   eax, 1111h
    mov   ebx, 2222h
    mov   ecx, 3333h
    ; ...

    ; 프로시저 종료 전 모든 레지스터 복원
    popad                    ; 스택 → 8개 범용 레지스터 (역순으로)
    ; 레지스터들이 pushad 직전 값으로 돌아옴

    ; ==========================================================
    ; 6. 응용 예제: 스택으로 문자열 뒤집기
    ;    알고리즘:
    ;      (1) 문자열을 앞에서부터 한 글자씩 스택에 PUSH
    ;          → 스택은 LIFO이므로 마지막 글자가 top에 위치
    ;      (2) 스택에서 한 글자씩 POP하며 원래 배열에 덮어씀
    ;          → 역순으로 꺼내지므로 문자열이 뒤집어짐
    ;
    ;    "ABCDE" → 스택 top: E, D, C, B, A
    ;            → POP 순서: E, D, C, B, A → "EDCBA"
    ; ==========================================================

    ; -- 1단계: 문자를 스택에 PUSH --
    mov   ecx, strLen            ; 루프 카운터 = 문자열 길이
    mov   esi, 0                 ; 인덱스

pushLoop:
    movzx eax, myStr[esi]        ; AL = myStr[i], 상위 비트 0 클리어
    push  eax                    ; eax에 있는 문자를 PUSH (32비트 단위로 저장)
    inc   esi
    loop  pushLoop
    ; 스택 상태: top → E(45h) / D / C / B / A(41h)
    ; -- 2단계: 스택에서 POP하여 덮어쓰기 --
    mov   ecx, strLen
    mov   esi, 0

popLoop:
    pop   eax                    ; top에서 문자 꺼내기
    mov   myStr[esi], al         ; myStr[i] = 꺼낸 문자
    inc   esi
    loop  popLoop
    ; myStr = "EDCBA\0" (뒤집힘)

    INVOKE ExitProcess, 0
main ENDP

END main
