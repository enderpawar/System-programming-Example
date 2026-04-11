; ============================================================
; 파일명  : 04_StringsAndArrays.asm
; 설  명  : 문자열, 배열, DUP 연산자, 세 변수 더하기 예제
;           (PDF 3장 - Defining BYTE Data: Strings, DUP Operator,
;                      A Program That Adds Variables)
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA

; ============================================================
; 문자열 정의 (Defining Strings)
; ============================================================

    ; 기본 문자열: 따옴표 안의 문자들을 ASCII 바이트로 저장
    ; "Hello" = 48h 65h 6Ch 6Ch 6Fh (5바이트)
    greeting    BYTE "Hello", 0         ; 널 종료 문자열 (null-terminated)

    ; CR(0Dh) + LF(0Ah) 조합: 줄바꿈
    ;   표준 출력에 쓸 때 커서를 다음 줄 맨 앞으로 이동시킴
    welcome     BYTE "Welcome!", 0Dh, 0Ah, 0

    ; 여러 줄에 걸쳐 문자열 정의: 레이블은 첫 번째 줄에만 붙임
    ; 이후 줄은 레이블 없이 이어서 정의
    longStr     BYTE "Assembly language is"
                BYTE " a low-level language.", 0Dh, 0Ah
                BYTE "It gives direct control", 0Dh, 0Ah
                BYTE "over hardware.", 0

    ; 줄 연속 문자(\): 소스 코드 두 줄을 하나의 데이터 정의로 합침
    ;   주의: \ 뒤에는 공백이나 다른 문자가 오면 안 됨
    combined    BYTE "First part ",\
                     "second part", 0

; ============================================================
; DUP 연산자 (DUP Operator)
;   형식: 횟수  DUP (초기값)
;   용도: 동일한 값을 여러 번 반복하여 공간 할당
;         배열이나 버퍼 초기화에 매우 유용
;   초기화/미초기화 데이터 모두에 사용 가능
; ============================================================

    ; 0으로 초기화된 10바이트 배열
    zeroBuf     BYTE 10 DUP(0)          ; {0,0,0,0,0,0,0,0,0,0}

    ; 미초기화 5바이트 배열 (값 예측 불가)
    undefBuf    BYTE 5 DUP(?)           ; {?,?,?,?,?}

    ; 특정 패턴 반복: 0ABh를 4번 반복
    pattern     BYTE 4 DUP(0ABh)        ; {ABh,ABh,ABh,ABh}

    ; 중첩 DUP: 바깥 DUP * 안쪽 DUP = 2 * 3 = 6바이트
    nested      BYTE 2 DUP(3 DUP(0FFh)) ; {FF,FF,FF,FF,FF,FF}

    ; WORD(2바이트) 배열을 DUP으로 선언
    wBuf        WORD 8 DUP(0)           ; 16바이트 (워드 8개)

    ; DWORD(4바이트) 배열을 DUP으로 선언
    dBuf        DWORD 4 DUP(?)          ; 16바이트 미초기화 (더블워드 4개)

; ============================================================
; 세 변수를 더하는 예제
;   (PDF 3장 - "A Program That Adds Variables" 예제)
;
;   중요 규칙: x86 명령어 집합은 메모리-메모리 직접 덧셈을 허용하지 않음!
;   따라서 레지스터를 중간 저장소로 사용해야 함
;     (예: val1 + val2 + val3 -> EAX를 거쳐야 함)
; ============================================================

    ; 세 개의 초기화된 DWORD 변수
    val1    DWORD 10000h
    val2    DWORD 40000h
    val3    DWORD 20000h
    sum     DWORD 0         ; 합계를 저장할 변수

.CODE
main PROC

    ; ---------------------------------------------------------
    ; 세 변수의 합산 과정:
    ;   [Step 1] val1 -> EAX
    ;   [Step 2] EAX = EAX + val2
    ;   [Step 3] EAX = EAX + val3
    ;   [Step 4] sum = EAX
    ; ---------------------------------------------------------

    mov eax, val1           ; EAX = 10000h
    add eax, val2           ; EAX = 10000h + 40000h = 50000h
    add eax, val3           ; EAX = 50000h + 20000h = 70000h
    mov sum, eax            ; sum = 70000h (메모리에 결과 저장)

    ; ---------------------------------------------------------
    ; 코드 레이블(Code Label) 예시:
    ;   - 레이블 이름 뒤에 콜론(:)을 붙여 선언
    ;   - 점프/루프 명령어의 대상 주소로 사용
    ;   - 같은 프로시저 안에서 레이블 이름은 유일해야 함
    ; ---------------------------------------------------------
    ; 아래는 무한루프 예시 (실제 실행하면 안됨, 구조 이해용)
    ; target:
    ;     nop
    ;     jmp target      ; target 레이블로 무조건 점프 -> 무한루프

    INVOKE ExitProcess, 0
main ENDP

END main
