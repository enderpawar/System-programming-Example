; ============================================================
; 파일명  : 12_Procedures.asm
; 설  명  : 프로시저(서브루틴) 정의와 호출 예제
;           - PROC / ENDP 디렉티브
;           - CALL / RET 동작 원리
;           - 프로시저 중첩 호출(Nested Calls)
;           - 레지스터 인수 전달(Passing Register Arguments)
;           - USES 연산자로 레지스터 자동 저장·복원
;           - 세 정수 합산 예제 (SumOfThree)
;           - 배열 합산 프로시저 예제 (ArraySum)
;           (PDF 5장 - Defining and Using Procedures)
; ============================================================
;
; ┌──────────────────────────────────────────────────────────┐
; │              [프로시저 핵심 개념 요약]                   │
; │                                                          │
; │  · 프로시저(Procedure) = 서브루틴(Subroutine)           │
; │    이름이 붙은 코드 블록으로, RET으로 종료               │
; │                                                          │
; │  · CALL 명령어                                          │
; │    1) 다음 명령어의 주소(복귀 주소)를 스택에 PUSH       │
; │    2) 피호출 프로시저의 주소를 EIP에 복사               │
; │                                                          │
; │  · RET 명령어                                           │
; │    스택에서 복귀 주소를 POP → EIP에 저장                │
; │    → 호출 이후 명령어부터 실행 재개                     │
; │                                                          │
; │  · 프로시저 내에서 레지스터를 수정할 경우               │
; │    반드시 PUSH/POP 또는 USES로 복원해야 함              │
; │    (단, 반환값 레지스터 EAX는 복원하면 안 됨)           │
; └──────────────────────────────────────────────────────────┘

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    ; ArraySum 예제용
    intArray    DWORD 10, 20, 30, 40, 50    ; 합산할 배열
    theSum      DWORD ?                      ; 합산 결과 저장

    ; 문서화 예제용
    x   SDWORD  3
    y   SDWORD  6
    z   SDWORD  1
    result SDWORD ?

.CODE

; ==========================================================
; ① SumOfThree  — 세 정수를 더해 EAX로 반환하는 프로시저
;
;   Receives : EAX, EBX, ECX (더할 세 DWORD 정수)
;   Returns  : EAX = EAX + EBX + ECX
;   Requires : 없음
;
;   설명:
;     · 레지스터를 통해 인수를 전달하는 가장 간단한 패턴
;     · 결과를 EAX로 반환하므로 EAX는 PUSH/POP 하지 않음
; ==========================================================
SumOfThree PROC
    ; EBX와 ECX를 EAX에 더해 합계를 EAX에 남김
    add   eax, ebx      ; EAX = EAX + EBX
    add   eax, ecx      ; EAX = EAX + EBX + ECX
    ret                 ; 스택에서 복귀 주소를 꺼내 EIP에 저장 → main으로 복귀
SumOfThree ENDP

; ==========================================================
; ② ArraySum  — 배열의 모든 원소 합계를 EAX로 반환하는 프로시저
;
;   Receives : ESI = 배열의 시작 오프셋 (포인터)
;              ECX = 배열 원소 개수
;   Returns  : EAX = 배열 원소의 합
;   Requires : 배열 원소는 DWORD(32비트) 크기여야 함
;
;   설명:
;     · ESI, ECX는 프로시저 내부에서 수정되므로 PUSH/POP으로 보존
;     · EAX는 반환값이므로 보존하지 않음
;     · 특정 변수명에 의존하지 않아 어떤 배열에도 재사용 가능
; ==========================================================
ArraySum PROC
    ; ESI, ECX 보존 (호출자의 레지스터 값을 보호)
    push  esi           ; ESI 저장
    push  ecx           ; ECX 저장

    mov   eax, 0        ; 누적 합계 초기화

sumLoop:
    add   eax, [esi]    ; EAX += 현재 원소 (간접 주소 지정)
    add   esi, 4        ; 다음 DWORD 원소로 이동 (+4바이트)
    loop  sumLoop       ; ECX-- ; ECX != 0이면 반복

    ; ESI, ECX 복원 (역순으로 POP)
    pop   ecx           ; ECX 복원
    pop   esi           ; ESI 복원
    ret
ArraySum ENDP

; ==========================================================
; ③ ArraySumWithUSES  — USES 연산자를 이용한 레지스터 자동 보존
;
;   · USES 뒤에 나열된 레지스터를 어셈블러가 자동으로
;     프로시저 시작 시 PUSH, 종료 시 POP 코드를 생성
;   · 효과: ArraySum과 완전히 동일하지만 코드가 간결함
;
;   주의: USES에 EAX를 포함시키면 반환값이 덮어써져 망가짐!
; ==========================================================
ArraySumWithUSES PROC USES esi ecx
    ; ↑ 어셈블러가 자동 삽입:  push esi / push ecx
    mov   eax, 0

sumsLoop:
    add   eax, [esi]
    add   esi, 4
    loop  sumsLoop
    ; ↓ 어셈블러가 자동 삽입:  pop ecx / pop esi
    ret
ArraySumWithUSES ENDP

; ==========================================================
; ④ Sub1 / Sub2  — 중첩 프로시저 호출(Nested Calls) 데모
;
;   중첩 호출 흐름:
;     main → Sub1 → Sub2
;     Sub2에서 RET → Sub1으로 복귀
;     Sub1에서 RET → main으로 복귀
;
;   스택은 LIFO이므로 복귀 주소가 올바른 순서로 관리됨
; ==========================================================
Sub2 PROC
    mov   ecx, 10       ; Sub2가 하는 작업 (예시)
    ret                 ; Sub1의 CALL Sub2 다음 명령어로 복귀
Sub2 ENDP

Sub1 PROC
    push  eax           ; 호출자(main)의 EAX 보존
    call  Sub2          ; Sub2 호출 → 복귀 주소(Sub1 내)가 스택에 PUSH
    pop   eax           ; EAX 복원
    ret                 ; main의 CALL Sub1 다음 명령어로 복귀
Sub1 ENDP

; ==========================================================
; ⑤ GlobalLabelDemo  — 전역 레이블(Global Label) 예제
;
;   · 기본적으로 레이블은 자신이 선언된 프로시저 내에서만 유효
;   · 레이블 뒤에 :: 를 붙이면 전역(global) 레이블이 됨
;     → 다른 프로시저에서도 JMP로 참조 가능
;
;   주의: 전역 레이블을 사용한 외부 JMP는 스택 정합성을
;         깨뜨릴 수 있으므로 설계상 권장하지 않음
; ==========================================================
GlobalLabelDemo PROC
    jmp   MyGlobalLabel          ; 전역 레이블로 점프 (같은 프로시저)
    mov   eax, 0                 ; 이 코드는 실행되지 않음

MyGlobalLabel::                  ; :: → 전역 레이블 선언
    mov   eax, 1
    ret
GlobalLabelDemo ENDP

; ==========================================================
; main — 진입점 프로시저
; ==========================================================
main PROC

    ; ---------------------------------------------------------
    ; SumOfThree 호출 예제
    ;   EAX, EBX, ECX에 더할 값을 미리 넣어두고 CALL
    ; ---------------------------------------------------------
    mov   eax, 10       ; 첫 번째 정수
    mov   ebx, 20       ; 두 번째 정수
    mov   ecx, 30       ; 세 번째 정수
    call  SumOfThree    ; EAX = 10 + 20 + 30 = 60
    ; call 직후 EAX = 60

    ; CALL/RET 동작을 직접 확인하고 싶다면 디버거에서
    ; call 실행 직전 ESP를 기록하고, SumOfThree 진입 직후
    ; [ESP]에 복귀 주소가 들어 있음을 확인할 것

    ; ---------------------------------------------------------
    ; ArraySum 호출 예제
    ;   인수 전달: ESI = 배열 오프셋, ECX = 원소 수
    ; ---------------------------------------------------------
    mov   esi, OFFSET intArray   ; ESI = &intArray[0]
    mov   ecx, LENGTHOF intArray ; ECX = 5
    call  ArraySum               ; EAX = 10+20+30+40+50 = 150
    mov   theSum, eax            ; 결과를 변수에 저장

    ; ---------------------------------------------------------
    ; ArraySumWithUSES 호출 (사용 방법 동일)
    ; ---------------------------------------------------------
    mov   esi, OFFSET intArray
    mov   ecx, LENGTHOF intArray
    call  ArraySumWithUSES       ; EAX = 150

    ; ---------------------------------------------------------
    ; 중첩 호출 예제
    ; ---------------------------------------------------------
    call  Sub1          ; main → Sub1 → Sub2 순서로 실행 후 복귀

    ; ---------------------------------------------------------
    ; 전역 레이블 데모 호출
    ; ---------------------------------------------------------
    call  GlobalLabelDemo

    ; ---------------------------------------------------------
    ; [중요] PUSH/POP 균형 법칙
    ;   PUSH 횟수 == POP 횟수여야 함
    ;   불균형하면 RET이 엉뚱한 주소로 복귀 → 프로그램 충돌
    ;
    ;   예: 다음은 잘못된 코드 (절대 하지 말 것!)
    ;     push eax
    ;     ret        ; EAX 값이 복귀 주소로 사용됨 → 충돌
    ; ---------------------------------------------------------

    ; ---------------------------------------------------------
    ; [중요] USES와 반환값
    ;   EAX를 반환값으로 쓰는 프로시저에서 USES나 PUSHAD를
    ;   사용하면 EAX가 복원되어 반환값이 사라짐!
    ;
    ;   잘못된 예:
    ;     BadProc PROC USES eax    ; ← EAX를 USES에 포함시키면 안 됨
    ;       mov eax, 99
    ;       ret   ; USES가 pop eax를 삽입 → EAX = 원래 값으로 덮어써짐
    ;     BadProc ENDP
    ; ---------------------------------------------------------

    INVOKE ExitProcess, 0
main ENDP

END main
