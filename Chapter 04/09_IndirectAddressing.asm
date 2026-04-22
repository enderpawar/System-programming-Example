; ============================================================
; 파일명  : 09_IndirectAddressing.asm
; 설  명  : 간접 주소지정 방식 예제
;           간접 피연산자 / 배열 순회 / 인덱스 피연산자 /
;           스케일 팩터 / 포인터 / TYPEDEF
;           (PDF 4장 - Indirect Addressing)
; ============================================================
;
; [직접 vs 간접 주소지정]
;   직접(Direct)   : 변수 이름 자체를 피연산자로 사용
;                    mov eax, myVar   -> 컴파일 시 주소가 고정됨
;                    배열의 여러 원소를 처리하기엔 비효율적
;
;   간접(Indirect) : 레지스터를 포인터처럼 사용
;                    레지스터가 가리키는 메모리 주소를 참조
;                    배열 처리, 반복 접근에 매우 유용
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

; ============================================================
; TYPEDEF - 사용자 정의 포인터 타입
;   TYPEDEF 는 데이터 세그먼트 앞에 선언하는 것이 일반적
;   내장 타입처럼 사용 가능하며 의도를 명확히 표현할 수 있음
; ============================================================
PBYTE   TYPEDEF PTR BYTE
PWORD   TYPEDEF PTR WORD
PDWORD  TYPEDEF PTR DWORD

.DATA
    ; 간접 피연산자 예제용
    myByte  BYTE  0AAh

    ; 배열 - BYTE (원소 간격: 1바이트)
    byteArr BYTE  10h, 20h, 30h, 40h, 50h

    ; 배열 - WORD (원소 간격: 2바이트)
    wordArr WORD  100h, 200h, 300h, 400h

    ; 배열 - DWORD (원소 간격: 4바이트)
    dwordArr DWORD 1000h, 2000h, 3000h, 4000h

    ; 32비트 정수 배열 합산 예제
    intArray DWORD 10000h, 20000h, 30000h, 40000h, 50000h
    arraySum DWORD 0

    ; 포인터 예제
    arrayB  BYTE  10h, 20h, 30h
    ptrB    DWORD OFFSET arrayB     ; arrayB의 시작 주소를 저장

    ; TYPEDEF 포인터 예제
    ptr1    PBYTE  OFFSET byteArr
    ptr2    PWORD  OFFSET wordArr
    ptr3    PDWORD OFFSET dwordArr

.CODE
main PROC

    ; ==========================================================
    ; 간접 피연산자 (Indirect Operands)
    ;   32비트 범용 레지스터를 대괄호 [ ]로 감싸서 사용 그러니까 주소를 넣어준다는거네 그
    ;   레지스터가 어떤 데이터의 주소를 담고 있다고 가정
    ;   [레지스터]는 그 주소가 가리키는 메모리 내용을 참조
    ; ==========================================================

    ; ESI에 myByte의 주소(오프셋)를 로드
    mov esi, OFFSET myByte      ; ESI = myByte의 주소

    ; [소스에 간접 피연산자 사용]: ESI가 가리키는 주소의 값을 AL에 복사
    mov al, [esi]               ; AL = myByte = 0AAh

    ; [목적지에 간접 피연산자 사용]: BL의 값을 ESI가 가리키는 주소에 저장
    mov bl, 0BBh
    mov [esi], bl               ; myByte = 0BBh

    ; ----------------------------------------------------------
    ; PTR + 간접 피연산자 (크기 명시)
    ;   간접 피연산자만으로는 크기가 불분명할 때 PTR로 명시
    ; ----------------------------------------------------------
    mov esi, OFFSET dwordArr

    ; [esi]의 크기가 불명확한 경우 - PTR로 크기 명시 필요
    ; inc [esi]          <- 오류! 크기 불명확
    inc DWORD PTR [esi] ; 올바름: DWORD(4바이트)로 역참조

    mov BYTE PTR [esi], 0FFh    ; 하위 1바이트만 0FFh로 설정

    ; ==========================================================
    ; 배열 순회 - 간접 주소지정으로 원소 접근
    ;   레지스터 값을 증가시켜 다음 원소로 이동
    ;   BYTE: +1, WORD: +2, DWORD: +4
    ; ==========================================================

    ; BYTE 배열 순회 (각 원소 +1씩 증가)
    mov esi, OFFSET byteArr     ; ESI = 배열 시작 주소
    mov al, [esi]               ; AL = byteArr[0] = 10h
    inc esi                     ; ESI += 1 (다음 BYTE 원소)
    mov al, [esi]               ; AL = byteArr[1] = 20h
    inc esi
    mov al, [esi]               ; AL = byteArr[2] = 30h

    ; WORD 배열 순회 (각 원소 +2씩 증가)
    mov esi, OFFSET wordArr
    mov ax, [esi]               ; AX = wordArr[0] = 100h
    add esi, 2                  ; ESI += 2 (다음 WORD 원소)
    mov ax, [esi]               ; AX = wordArr[1] = 200h
    add esi, 2
    mov ax, [esi]               ; AX = wordArr[2] = 300h

    ; DWORD 배열 순회 (각 원소 +4씩 증가)
    mov esi, OFFSET dwordArr
    mov eax, [esi]              ; EAX = dwordArr[0] = 1000h
    add esi, 4                  ; ESI += 4 (다음 DWORD 원소)
    mov eax, [esi]              ; EAX = dwordArr[1] = 2000h

    ; ==========================================================
    ; 인덱스 피연산자 (Indexed Operands)
    ;   레지스터와 상수 오프셋을 결합해 유효 주소를 생성
    ;   두 가지 표기법 (MASM에서 모두 유효):
    ;     형식 1: [배열이름 + 레지스터]  (변수 이름 + 인덱스 레지스터)
    ;     형식 2: [레지스터 + 상수]      (베이스 레지스터 + 상수 변위)
    ; ==========================================================

    ; [형식 1: 배열이름 + 인덱스 레지스터]
    ;   배열 이름은 어셈블러가 상수 오프셋으로 변환
    ;   인덱스 레지스터는 0으로 초기화한 후 시작하는 것이 일반적
    mov esi, 0
    mov al, byteArr[esi]        ; AL = byteArr[0]
    mov al, [byteArr + esi]     ; 위와 동일한 표현
    inc esi
    mov al, [byteArr + esi]     ; AL = byteArr[1]

    ; WORD 배열 - 인덱스는 바이트 단위이므로 +2씩 증가
    mov esi, 0
    mov ax, wordArr[esi]        ; AX = wordArr[0]
    mov esi, 2
    mov ax, wordArr[esi]        ; AX = wordArr[1] (+2바이트 후)

    ; [형식 2: 베이스 레지스터 + 상수 변위]
    ;   레지스터가 배열의 베이스 주소를 가지고, 상수가 오프셋 역할
    mov esi, OFFSET byteArr     ; ESI = 배열 시작 주소
    mov al, [esi]               ; AL = byteArr[0]
    mov al, [esi + 1]           ; AL = byteArr[1]
    mov al, [esi + 2]           ; AL = byteArr[2]

    ; ==========================================================
    ; 스케일 팩터 (Scale Factors)
    ;   인덱스 * 원소크기 를 자동으로 계산해주는 기능
    ;   형식: [배열 + 인덱스 * 스케일]
    ;     WORD  스케일 = 2
    ;     DWORD 스케일 = 4
    ;     QWORD 스케일 = 8
    ;   컴파일러 작성자들을 위해 Intel이 제공한 편의 기능
    ; ==========================================================

    ; 스케일 없이 DWORD 배열 접근 (인덱스를 직접 4배로 계산)
    mov esi, 2                          ; 원소 인덱스 = 2
    mov eax, [dwordArr + esi * 4]       ; EAX = dwordArr[2] = 3000h
    ; esi * 4 : 인덱스 2 -> 바이트 오프셋 8

    ; 스케일 팩터로 WORD 배열 접근
    mov esi, 1                          ; 원소 인덱스 = 1
    mov ax, [wordArr + esi * 2]         ; AX = wordArr[1] = 200h

    ; ==========================================================
    ; 포인터 (Pointers)
    ;   다른 변수의 주소를 담는 변수
    ;   32비트 모드: DWORD 변수에 주소 저장 (32비트 near pointer)
    ;   런타임에 주소를 변경할 수 있어 배열/자료구조 처리에 유용
    ; ==========================================================

    ; ptrB 변수에 저장된 arrayB의 주소를 ESI에 로드
    mov esi, ptrB               ; ESI = arrayB의 주소
    mov al, [esi]               ; AL = arrayB[0] = 10h
    inc esi
    mov al, [esi]               ; AL = arrayB[1] = 20h

    ; TYPEDEF로 만든 포인터 타입 사용
    ; ptr1(PBYTE)에 저장된 byteArr 주소를 ESI에 로드
    mov esi, ptr1               ; ESI = byteArr의 주소
    mov al, [esi]               ; AL = byteArr[0]

    ; ptr3(PDWORD)에 저장된 dwordArr 주소를 ESI에 로드
    mov esi, ptr3               ; ESI = dwordArr의 주소
    mov eax, [esi]              ; EAX = dwordArr[0]
    add esi, 4
    mov eax, [esi]              ; EAX = dwordArr[1]

    ; ==========================================================
    ; 32비트 정수 배열 합산 예제 (루프 + 간접 주소지정)
    ;   (PDF 4장 - Adding 32-Bit Integers 예제)
    ;   intArray = {10000h, 20000h, 30000h, 40000h, 50000h}
    ;   기대 결과: arraySum = F0000h
    ; ==========================================================
    mov esi, OFFSET intArray    ; ESI = 배열 시작 주소
    mov ecx, LENGTHOF intArray  ; ECX = 5 (배열 원소 수, 루프 카운터)
    mov eax, 0                  ; EAX = 0 (누적 합계 초기화)

L1:
    add eax, [esi]              ; EAX += 현재 원소
    add esi, TYPE intArray      ; ESI += 4 (다음 DWORD 원소로 이동)
    loop L1                     ; ECX-- , ECX != 0이면 L1으로 점프

    mov arraySum, eax           ; 합계를 메모리에 저장 (= F0000h)

    INVOKE ExitProcess, 0

main ENDP

END main
