; ============================================================
; 파일명  : 08_DataOperators.asm
; 설  명  : 데이터 관련 연산자와 디렉티브 예제
;           OFFSET / ALIGN / PTR / TYPE / LENGTHOF / SIZEOF / LABEL
;           (PDF 4장 - Data-Related Operators and Directives)
; ============================================================
;
; 데이터 관련 연산자/디렉티브는 실행 명령어가 아님
;   -> 어셈블러가 어셈블 시간(assembly time)에 해석
;   -> 변수의 주소, 크기, 타입 정보 등을 얻는 데 사용
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

; ============================================================
; TYPEDEF 연산자 - 사용자 정의 포인터 타입 생성
;   데이터 세그먼트(.DATA) 앞에 선언하는 것이 일반적
;   TYPEDEF는 기존 내장 타입처럼 변수 선언에 사용 가능
; ============================================================
PBYTE   TYPEDEF PTR BYTE    ; 바이트를 가리키는 포인터 타입
PWORD   TYPEDEF PTR WORD    ; 워드를 가리키는 포인터 타입
PDWORD  TYPEDEF PTR DWORD   ; 더블워드를 가리키는 포인터 타입

.DATA

    ; ===========================================================
    ; OFFSET 연산자 예제용 변수
    ;   OFFSET: 데이터 레이블의 오프셋(세그먼트 시작으로부터 거리, 바이트)을 반환
    ;   포인터처럼 활용: 변수의 주소를 DWORD 변수에 저장 가능
    ; ===========================================================
    bVal    BYTE  'A'
    wVal    WORD  1000h
    dVal    DWORD 12345678h
    dVal2   DWORD 0FFFFFFFFh

    ; 다른 변수의 오프셋을 저장 -> 포인터 역할
    pByte   DWORD OFFSET bVal   ; pByte = bVal의 주소 (포인터)

    ; 배열과 OFFSET
    bigArray    DWORD 10 DUP(0)
    pArray      DWORD OFFSET bigArray   ; 배열 시작 주소를 저장하는 포인터

    ; ===========================================================
    ; ALIGN 디렉티브
    ;   변수를 특정 바이트 경계(boundary)에 정렬
    ;   경계: 1(기본), 2, 4, 8, 16
    ;   필요시 어셈블러가 빈 바이트를 앞에 삽입하여 정렬
    ;
    ;   x86 CPU는 짝수 주소(aligned)에 놓인 데이터를
    ;   홀수 주소에 놓인 데이터보다 더 빠르게 처리함
    ; ===========================================================
    bAlign  BYTE  'X'           ; 이 변수 다음은 1바이트 경계
    ALIGN 2                     ; 다음 변수를 2바이트 경계에 정렬 (홀수면 1바이트 패딩 삽입)
    wAlign  WORD  2000h         ; 2바이트 경계에 배치됨
    ALIGN 4                     ; 다음 변수를 4바이트 경계에 정렬
    dAlign  DWORD 3000h         ; 4바이트(더블워드) 경계에 배치됨

    ; ===========================================================
    ; PTR 연산자 예제용 변수
    ;   PTR: 피연산자의 선언된 크기를 재정의(override)할 때 사용
    ;   어셈블러가 기본적으로 가정하는 크기와 다른 크기로 접근할 때 필요
    ;   리틀 엔디안 저장 방식 때문에 하위 바이트가 낮은 주소에 위치
    ; ===========================================================
    myDouble    DWORD   12345678h   ; 메모리: 78h 56h 34h 12h (리틀 엔디안)

    ; LABEL 디렉티브 예제 (LABEL 섹션에서 함께 설명)
    val32       DWORD   12345678h
                                    ; val16은 val32와 같은 주소를 공유 (스토리지 미할당)

    ; ===========================================================
    ; TYPE / LENGTHOF / SIZEOF 예제용 배열
    ; ===========================================================
    byteArr     BYTE    10, 20, 30, 40, 50          ; 5바이트
    wordArr     WORD    100, 200, 300, 400           ; 4워드 = 8바이트
    dwordArr    DWORD   1000, 2000, 3000             ; 3더블워드 = 12바이트

    ; 여러 줄로 정의된 배열 (LENGTHOF는 레이블과 같은 줄의 원소만 셈)
    myArray     WORD    1, 2, 3, 4, 5               ; 5개
                WORD    6, 7, 8, 9, 10              ; 추가 5개
    ; LENGTHOF myArray = 5 (레이블과 같은 첫 줄의 원소만)
    ; SIZEOF   myArray = 10 * 2 = 20 바이트

    ; ===========================================================
    ; TYPEDEF로 만든 포인터 타입 활용
    ; ===========================================================
    ptr1        PBYTE  OFFSET byteArr   ; byteArr의 주소를 담는 PBYTE 포인터
    ptr2        PWORD  OFFSET wordArr   ; wordArr의 주소를 담는 PWORD 포인터

.CODE
main PROC

    ; ==========================================================
    ; OFFSET 연산자 사용
    ;   레지스터에 변수의 주소를 로드하면 포인터처럼 사용 가능
    ; ==========================================================
    ; bVal의 오프셋(주소)을 ESI에 로드
    mov esi, OFFSET bVal        ; ESI = bVal의 메모리 주소
    ; 이제 [ESI]로 bVal에 접근 가능 (간접 주소지정)
    mov al, [esi]               ; AL = bVal = 'A'

    ; DWORD 포인터 변수(pArray)에 저장된 주소를 ESI에 복사
    mov esi, pArray             ; ESI = bigArray의 시작 주소
    ; ESI를 통해 배열 첫 번째 원소에 접근
    mov eax, [esi]              ; EAX = bigArray[0]

    ; OFFSET으로 배열 중간 원소의 주소 계산 후 ESI에 로드
    ; ESI = bigArray + 2*4 = bigArray의 세 번째 원소 주소
    mov esi, OFFSET bigArray + 8    ; bigArray[2]의 주소

    ; ==========================================================
    ; PTR 연산자 사용
    ;   선언된 크기와 다른 크기로 메모리에 접근할 때 사용
    ;   PTR 뒤에는 BYTE, SBYTE, WORD, SWORD, DWORD, SDWORD 등 사용 가능
    ; ==========================================================

    ; myDouble = 12345678h
    ; 리틀 엔디안 메모리 배치: [주소+0]=78h, [+1]=56h, [+2]=34h, [+3]=12h

    ; DWORD로 선언된 변수를 WORD로 접근 (하위 16비트)
    mov ax, WORD PTR myDouble       ; AX = 5678h (하위 워드)

    ; BYTE로 접근 (가장 낮은 바이트)
    mov al, BYTE PTR myDouble       ; AL = 78h (최하위 바이트)
    mov al, BYTE PTR [myDouble + 1] ; AL = 56h (두 번째 바이트)
    mov al, BYTE PTR [myDouble + 3] ; AL = 12h (최상위 바이트)

    ; 작은 값을 큰 목적지에 복사 - DWORD PTR 활용
    ; 주의: mov eax, WORD PTR myDouble 처럼 크기 불일치를 해결
    movzx eax, WORD PTR myDouble    ; EAX = 00005678h (제로 확장)

    ; ==========================================================
    ; TYPE 연산자 - 변수 한 원소의 크기(바이트)를 반환
    ;   어셈블 시간에 평가되는 상수
    ; ==========================================================
    ; TYPE byteArr  = 1 (BYTE = 1바이트)
    ; TYPE wordArr  = 2 (WORD = 2바이트)
    ; TYPE dwordArr = 4 (DWORD = 4바이트)

    ; TYPE를 활용한 다음 원소 접근 (DWORD 배열)
    mov esi, OFFSET dwordArr
    mov eax, [esi]                      ; dwordArr[0]
    mov eax, [esi + TYPE dwordArr]      ; dwordArr[1] (esi + 4)
    mov eax, [esi + TYPE dwordArr * 2]  ; dwordArr[2] (esi + 8)

    ; ==========================================================
    ; LENGTHOF 연산자 - 배열의 원소 개수를 반환
    ; SIZEOF   연산자 - 배열이 차지하는 전체 바이트 수를 반환
    ;   SIZEOF = LENGTHOF * TYPE
    ;
    ;   활용: 루프 카운터 초기화, 범위 확인 등
    ; ==========================================================
    ; LENGTHOF byteArr  = 5   (원소 5개)
    ; SIZEOF   byteArr  = 5   (5 * 1 = 5바이트)
    ; LENGTHOF wordArr  = 4   (원소 4개)
    ; SIZEOF   wordArr  = 8   (4 * 2 = 8바이트)
    ; LENGTHOF dwordArr = 3   (원소 3개)
    ; SIZEOF   dwordArr = 12  (3 * 4 = 12바이트)

    ; 배열 원소 수를 ECX 루프 카운터로 사용 (LENGTHOF 활용)
    mov ecx, LENGTHOF dwordArr  ; ECX = 3 (반복 횟수)
    mov esi, OFFSET dwordArr
    mov eax, 0
sumLoop:
    add eax, [esi]              ; 배열 원소를 EAX에 누적
    add esi, TYPE dwordArr      ; ESI를 다음 원소로 이동 (4바이트)
    loop sumLoop                ; ECX가 0이 될 때까지 반복

    ; ==========================================================
    ; LABEL 디렉티브 - 스토리지를 할당하지 않고 레이블+크기 속성 삽입
    ;   같은 저장 공간을 다른 이름과 크기로 접근할 때 유용
    ;   예) DWORD 변수를 WORD 단위로도 읽고 싶을 때
    ; ==========================================================

    .DATA
        ; val16은 val32와 동일한 주소, 스토리지는 새로 할당되지 않음
        val16   LABEL WORD          ; val32의 하위 16비트를 WORD로 접근하는 별칭
        val32b  DWORD 0ABCD1234h    ; 실제 4바이트 저장소

    .CODE
    ; val32b = 0ABCD1234h
    ; val16  = 1234h (동일 주소, WORD 크기로 접근)
    mov ax, val16               ; AX = 1234h (하위 16비트)
    mov eax, val32b             ; EAX = 0ABCD1234h (전체 32비트)

    INVOKE ExitProcess, 0
main ENDP

END main
