; ============================================================
; 파일명  : 10_JMP_LOOP.asm
; 설  명  : JMP / LOOP 명령어, 배열 합산, 문자열 복사 예제
;           (PDF 4장 - JMP and LOOP Instructions)
; ============================================================
;
; [제어 전달(Transfer of Control)의 두 종류]
;   1) 무조건 전달(Unconditional Transfer)
;      - 항상 지정한 위치로 점프
;      - JMP 명령어 사용
;
;   2) 조건부 전달(Conditional Transfer)
;      - 특정 조건(CPU 플래그 상태)이 참일 때만 점프
;      - ECX 및 Flags 레지스터의 값을 기반으로 판단
;      - IF문, 루프 같은 고수준 로직을 구현하는 기반
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    ; LOOP 예제용
    count   DWORD 0         ; 루프 실행 횟수 저장

    ; 중첩 루프 예제용 - 외부 루프 카운터를 저장하는 변수
    outerCount  DWORD 0

    ; 배열 합산 예제 (PDF 4장 예제)
    intArray    DWORD 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    arraySum    DWORD 0

    ; 문자열 복사 예제 (PDF 4장 예제)
    source  BYTE "Hello, Assembly!", 0     ; 원본 문자열 (널 종료)
    target  BYTE SIZEOF source DUP(0)      ; 복사본 저장 공간

.CODE
main PROC

    ; ==========================================================
    ; JMP 명령어 - 무조건 점프 (Unconditional Transfer)
    ;   목적지 레이블의 오프셋을 명령어 포인터(EIP)에 로드
    ;   -> 프로그램 실행이 그 레이블 위치에서 이어짐
    ;   형식: JMP 레이블
    ;
    ;   JMP 단독으로는 무한 루프가 됨
    ;   루프를 빠져나오려면 조건 점프(conditional jump)와 함께 사용
    ; ==========================================================

    ; 간단한 JMP 예시 - 아래 구간을 건너뜀
    jmp skip_section        ; skip_section 레이블로 무조건 점프
    
    ; 이 코드는 실행되지 않음 (JMP가 건너뜀)
    mov eax, 0FFFFFFFFh     ; 절대 실행 안 됨

skip_section:
    mov eax, 0              ; EAX = 0 (이 위치부터 실행)

    ; ==========================================================
    ; LOOP 명령어 - ECX를 카운터로 사용한 반복 (Loop by Counter)
    ;   형식: LOOP 레이블
    ;
    ;   실행 과정:
    ;     1) ECX를 1 감소
    ;     2) ECX != 0 이면 레이블로 점프 (반복 계속)
    ;        ECX == 0 이면 점프하지 않고 다음 명령어로 진행 (루프 종료)
    ;
    ;   제약: 점프 목적지가 현재 위치로부터 -128 ~ +127 바이트 이내여야 함
    ;
    ;   치명적 실수: ECX를 0으로 초기화한 채 루프 시작하면
    ;     첫 번째 LOOP에서 ECX = 0 - 1 = FFFFFFFFh (약 42억 번 반복!)
    ; ==========================================================

    ; ECX를 5로 설정해 5번 반복하는 루프
    mov ecx, 5              ; 루프 5회 반복
    mov eax, 0              ; 누적 합계 초기화

loopDemo:
    ; 루프 본체: 1~5까지 더하기 (각 반복에서 ECX 값을 더함)
    add eax, ecx            ; EAX += ECX (5, 4, 3, 2, 1 순으로)
    loop loopDemo           ; ECX-- , ECX != 0이면 loopDemo로 점프
    ; 루프 종료 후: EAX = 5+4+3+2+1 = 15, ECX = 0

    ; ==========================================================
    ; 루프 내에서 ECX를 수정해야 할 때
    ;   루프 시작 직전에 변수에 ECX를 저장하고
    ;   LOOP 직전에 복원하면 됨
    ; ==========================================================
    mov ecx, 3

saveLoop:
    mov count, ecx          ; ECX를 변수에 저장 (백업)
    ; -- ECX를 사용하는 내부 작업 --
    mov ecx, 10             ; ECX를 다른 용도로 사용 (잠시 변경)
    ; ... (내부 작업) ...
    mov ecx, count          ; ECX 복원 (LOOP 직전에 반드시 복원!)
    loop saveLoop           ; 복원된 ECX 기준으로 반복

    ; ==========================================================
    ; 중첩 루프 (Nested Loops)
    ;   외부 루프 카운터(ECX)를 변수에 저장해 내부 루프와 분리
    ;   일반 규칙: 2단계 이상의 중첩은 서브루틴(함수)으로 분리 권장
    ; ==========================================================
    mov ecx, 3              ; 외부 루프: 3회

outerLoop:
    mov outerCount, ecx     ; 외부 ECX 백업

    mov ecx, 5              ; 내부 루프: 5회
innerLoop:
    ; -- 내부 루프 본체 --
    nop                     ; 아무 동작 없음 (구조 이해용)
    loop innerLoop          ; 내부 루프 (ECX = 5 -> 0)

    mov ecx, outerCount     ; 외부 ECX 복원
    loop outerLoop          ; 외부 루프 (ECX = 3 -> 0)
    ; 총 실행 횟수: 내부 루프 5 * 외부 루프 3 = 15회

    ; ==========================================================
    ; 배열 합산 예제 (Summing an Integer Array)
    ;   PDF 4장 예제 - 7단계 절차:
    ;     1) 배열 주소를 인덱스 피연산자용 레지스터에 할당
    ;     2) 루프 카운터를 배열 길이로 초기화
    ;     3) 합계 레지스터를 0으로 초기화
    ;     4) 루프 시작 레이블 선언
    ;     5) 루프 본체: 원소를 합계에 누적
    ;     6) 다음 원소로 이동 (인덱스 레지스터 증가)
    ;     7) LOOP 명령어로 반복
    ; ==========================================================

    ; [1] 배열 주소 로드
    mov esi, OFFSET intArray        ; ESI = intArray 시작 주소

    ; [2] 루프 카운터 = 배열 원소 수
    mov ecx, LENGTHOF intArray      ; ECX = 10

    ; [3] 합계 레지스터 초기화
    mov eax, 0                      ; EAX = 0 (누적 합계)

    ; [4] 루프 시작 레이블
sumLoop:
    ; [5] 현재 원소를 EAX에 누적
    add eax, [esi]                  ; EAX += intArray[i]

    ; [6] 다음 원소로 이동 (DWORD = 4바이트)
    add esi, TYPE intArray          ; ESI += 4 
    
    ; [7] 반복
    loop sumLoop                    ; ECX-- , ECX != 0이면 sumLoop로

    ; 결과 저장
    mov arraySum, eax               ; arraySum = 1+2+...+10 = 55

    ; ==========================================================
    ; 문자열 복사 예제 (Copying a String)
    ;   source 문자열을 target에 한 글자씩 복사
    ;   MOV는 메모리-메모리 직접 이동 불가
    ;   -> 각 문자를 AL을 거쳐 복사 (source -> AL -> target)
    ;
    ;   source = "Hello, Assembly!" + 널(0)
    ;   SIZEOF source 바이트만큼 복사 (널 문자 포함)
    ; ==========================================================

    mov esi, 0                      ; 인덱스 0 으로 초기화
    mov ecx, SIZEOF source          ; ECX = 문자열 전체 바이트 수 (널 포함)

copyLoop:
    mov al, source[esi]             ; AL = source의 i번째 문자
    mov target[esi], al             ; target의 i번째 위치에 복사
    inc esi                         ; 인덱스 1 증가
    loop copyLoop                   ; 모든 바이트 복사 완료까지 반복
    ; 루프 종료 후: target = "Hello, Assembly!\0" (source와 동일)

    INVOKE ExitProcess, 0
main ENDP

END main
