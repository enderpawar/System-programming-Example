; ============================================================
; 파일명  : 05_SymbolicConstants.asm
; 설  명  : 심볼릭 상수 - =, EQU, TEXTEQU 디렉티브 예제
;           (PDF 3장 - Symbolic Constants)
; ============================================================
;
; 심볼릭 상수(Symbolic Constant)란?
;   - 식별자(이름)에 정수 표현식 또는 임의 텍스트를 연결
;   - 메모리를 예약하지 않음 (변수와 다름)
;   - 어셈블러가 소스 파일을 스캔할 때만 사용
;   - 런타임에는 변경 불가
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

; ============================================================
; 1. 등호 디렉티브 (Equal-Sign Directive: =)
;    형식:  이름 = 정수표현식
;    용도:  정수 표현식에 이름(심볼)을 붙임
;    특징:  같은 소스 파일 안에서 재정의(재할당) 가능
;
;    장점: 숫자 대신 의미 있는 이름을 사용하면
;         프로그램을 읽고 유지하기 쉬워짐
; ============================================================

; 키보드 스캔 코드를 의미 있는 이름으로 정의
Esc_Key     = 1Bh          ; ESC 키의 ASCII 코드
Enter_Key   = 0Dh          ; Enter 키의 ASCII 코드
Tab_Key     = 09h          ; Tab 키의 ASCII 코드

; 수식으로 정의
COUNT       = 10            ; 루프 횟수
BUFFER_SIZE = COUNT * 4     ; COUNT에 따라 자동 계산 (40)

; 재정의(Redefinition): = 로 정의한 심볼은 같은 파일에서 재할당 가능
LIMIT = 100
LIMIT = 200                 ; LIMIT를 200으로 재정의 (합법적)
; 주의: 재정의 순서는 런타임 실행 순서와 무관 (어셈블 시간에 처리됨)

; ============================================================
; 현재 위치 카운터 $ (Current Location Counter)
;   - $는 현재 프로그램 문장의 오프셋을 반환하는 특수 심볼
;   - 배열이나 문자열의 크기를 자동으로 계산하는 데 유용
;   - ListSize는 list 바로 뒤에 와야 올바른 크기를 얻음
;
;   계산 원리:
;     ListSize = $ (현재 오프셋) - list (list 시작 오프셋)
;              = list가 차지하는 바이트 수
; ============================================================

.DATA

; 바이트 배열 크기 자동 계산
list        BYTE 10, 20, 30, 40, 50
ListSize    = ($ - list)        ; = 5 (바이트 5개이므로)

; WORD 배열: 원소 개수 = 전체 바이트 / 원소 크기(2)
wList       WORD 100, 200, 300, 400
wListSize   = ($ - wList) / 2  ; = 4 (원소 4개)

; DWORD 배열: 원소 개수 = 전체 바이트 / 원소 크기(4)
dList       DWORD 1000, 2000, 3000
dListSize   = ($ - dList) / 4  ; = 3 (원소 3개)

; selfPtr: 자기 자신의 오프셋으로 초기화 (현재 위치 저장)
selfPtr     DWORD $             ; selfPtr = selfPtr 자신의 오프셋

; DUP의 카운터를 심볼릭 상수로 표현하면 유지보수가 쉬워짐
BufCount    = 20
myBuf       BYTE BufCount DUP(0)  ; 크기를 바꾸려면 BufCount만 수정하면 됨

; ============================================================
; 2. EQU 디렉티브
;    세 가지 형식:
;      (1) 이름 EQU 정수표현식
;      (2) 이름 EQU 기존심볼이름
;      (3) 이름 EQU <임의의텍스트>
;
;    특징:
;      - 정수가 아닌 값도 정의 가능 (텍스트 포함)
;      - = 과 달리 같은 소스 파일에서 재정의 불가
;        (실수로 같은 이름에 다른 값을 쓰는 오류 방지)
; ============================================================

; 형식 1: 정수 표현식 (= 과 유사)
ROWS        EQU 5
COLS        EQU 10
MATRIX_SIZE EQU ROWS * COLS    ; = 50

; 형식 2: 기존 심볼에 별칭 붙이기
ROW_COUNT   EQU ROWS           ; ROWS와 동일한 값

; 형식 3: 꺾쇠 괄호 <...> 안에 임의 텍스트 포함
;   나중에 어셈블러가 이 이름을 만나면 텍스트로 대체함
PI          EQU <3.14159>      ; 정수가 아닌 실수 텍스트
PressKey    EQU <"Press any key...", 0>

; EQU 활용 예: 배열 선언에서 매트릭스 크기를 텍스트로 재사용
; matrix1 REAL4 MATRIX_SIZE DUP(0.0) -- 정수 EQU 사용
; M1       = ROWS * COLS              -- 어셈블러가 수식 평가
; M2      EQU <ROWS * COLS>           -- 텍스트 그대로 삽입

; 재정의 불가 예시 (아래 주석을 해제하면 어셈블 오류 발생):
; ROWS EQU 999   ; 오류! EQU로 정의한 심볼은 재정의 금지

; ============================================================
; 3. TEXTEQU 디렉티브 (Text Macro)
;    세 가지 형식:
;      (1) 이름 TEXTEQU <텍스트>         -- 텍스트 직접 할당
;      (2) 이름 TEXTEQU 기존텍스트매크로  -- 기존 텍스트 매크로 복사
;      (3) 이름 TEXTEQU %(정수표현식)     -- 정수를 텍스트로 변환 후 할당
;
;    EQU 형식3과의 차이:
;      - TEXTEQU는 같은 소스 파일에서 재정의 가능
;      - 텍스트 매크로끼리 서로 참조하여 조합 가능
; ============================================================

; 형식 1: 텍스트 직접 할당 (TEXTEQU)
myStr   TEXTEQU <"Hello World", 0>

; 형식 3: 정수 표현식을 텍스트로 변환 (%: 정수 -> 텍스트)
rowStr  TEXTEQU %(ROWS)     ; "5" 라는 텍스트

; 텍스트 매크로는 서로 조합(중첩)할 수 있음
moveVal TEXTEQU <mov eax>   ; "mov eax" 텍스트
count5  TEXTEQU %(ROWS)     ; "5" 텍스트

; TEXTEQU로 정의한 심볼은 재정의 가능 (EQU와의 차이점)
myStr   TEXTEQU <"Updated String", 0>   ; 재정의 가능

.DATA
    msg     BYTE myStr          ; TEXTEQU 확장: BYTE "Updated String", 0

.CODE
main PROC

    ; 심볼릭 상수를 명령어에서 직접 사용
    ; 어셈블러가 COUNT를 10으로 치환함
    mov ecx, COUNT          ; ECX = 10 (COUNT 심볼 -> 어셈블 시간에 10으로 대체)
    mov eax, BUFFER_SIZE    ; EAX = 40 (BUFFER_SIZE 심볼 사용)

    ; $ 카운터로 계산한 배열 크기 사용
    mov ecx, ListSize       ; ECX = 5 (list 배열 원소 수)
    mov ecx, wListSize      ; ECX = 4 (wList 배열 원소 수)

    INVOKE ExitProcess, 0
main ENDP

END main
