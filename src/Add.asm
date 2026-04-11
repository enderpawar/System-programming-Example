; ============================================================
; 파일명  : Add.asm
; 설  명  : 두 정수를 더해 변수에 저장하는 예제
;           (PDF 3장 - Adding a Variable to the AddTwo Program)
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

; .DATA 디렉티브: 데이터 세그먼트의 시작을 알리는 지시어
;   - 기계어로 번역되지 않음 (런타임에 실행되는 명령어가 아님)
;   - 변수(데이터)를 정의하는 공간
.DATA
    ; DWORD: 32비트(4바이트) 부호 없는 정수 변수 선언
    ; sum 이름의 변수를 선언하고 초기값을 0으로 설정
    sum DWORD 0

; .CODE 디렉티브: 코드 세그먼트의 시작을 알리는 지시어
;   - 이 역시 디렉티브(Directive)로, 기계어로 번역되지 않음
;   - 이 이후에 나오는 명령어들이 실행 가능한 코드
.CODE
main PROC
    ; mov eax, 5
    ;   - 정수 리터럴 5를 EAX 레지스터에 복사
    ;   - 메모리 변수끼리 직접 연산 불가 -> 레지스터를 거쳐야 함
    mov eax, 5

    ; add eax, 6
    ;   - EAX(현재 값: 5)에 정수 리터럴 6을 더함
    ;   - 결과: EAX = 11
    add eax, 6

    ; mov sum, eax
    ;   - EAX(11)의 값을 메모리 변수 sum에 저장
    ;   - x86은 "메모리 <- 메모리" 직접 이동 불가
    ;     반드시 레지스터(eax)를 중간 단계로 사용해야 함
    mov sum, eax

    INVOKE ExitProcess, 0   ; 프로그램 종료
main ENDP

END main