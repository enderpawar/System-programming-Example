; ╔══════════════════════════════════════════════════════════════════╗
; ║          2025 시스템 프로그래밍 중간고사 예제 코드 총정리        ║
; ║          3장 · 4장 · 5장 전체 핵심 예제 한 파일 집결            ║
; ║          (학습/복습 전용 — 빌드 목적 아님)                      ║
; ╚══════════════════════════════════════════════════════════════════╝
;
;  파일 구성:
;   [CH3-1]  프로그램 기본 구조 & 어셈블-링크 사이클
;   [CH3-2]  데이터 타입 & 리틀 엔디안
;   [CH3-3]  DUP / .DATA? / 코드-데이터 혼합
;   [CH3-4]  심볼릭 상수 — = / $ / EQU / TEXTEQU
;   [CH4-1]  MOV 규칙 & 겹치는 레지스터
;   [CH4-2]  MOVZX / MOVSX (크기 불일치 해결)
;   [CH4-3]  INC / DEC / ADD / SUB / NEG & CPU 플래그
;   [CH4-4]  OFFSET / ALIGN / PTR / TYPE / LENGTHOF / SIZEOF / LABEL
;   [CH4-5]  간접 주소지정 & 인덱스 피연산자 & 스케일 팩터
;   [CH4-6]  JMP / LOOP — 배열 합산 & 문자열 복사 패턴
;   [CH5-1]  런타임 스택 — PUSH / POP / PUSHFD / PUSHAD
;   [CH5-2]  스택 응용 — 문자열 뒤집기
;   [CH5-3]  CALL / RET & 프로시저 정의 (PROC/ENDP)
;   [CH5-4]  ArraySum 프로시저 & USES 연산자
;   [CH5-5]  중첩 호출 & 전역 레이블
;   [CH5-6]  Irvine32 라이브러리 — 입출력 / 색상 / 난수 / 디버그


; ══════════════════════════════════════════════════════════════════
; [CH3-1]  프로그램 기본 구조 & 어셈블-링크-실행 사이클
; ══════════════════════════════════════════════════════════════════
;
;  어셈블-링크-실행 사이클:
;    소스(.asm) → [Assembler] → 오브젝트(.obj) → [Linker+.lib] → 실행(.exe)
;    · Assembler : 소스를 기계어로 번역, 링커가 채울 주소는 0으로 둠
;    · Linker    : CALL 목적지 주소를 라이브러리(.lib)에서 가져와 채움
;    · OS Loader : .exe를 메모리에 올려 진입점(main)부터 실행
;
;  디렉티브(Directive) vs 명령어(Instruction):
;    디렉티브 → 어셈블 시간에만 처리, 기계어 생성 안 함 (예: .DATA, DWORD, PROC)
;    명령어   → 기계어로 번역되어 런타임에 CPU가 실행    (예: MOV, ADD, LOOP)
;
;  명령어 구성 4요소:  [레이블:]  니모닉  [피연산자]  [; 주석]
;    · 레이블 : 코드 레이블엔 반드시 콜론(:) 붙임  → target:
;    · 니모닉 : 명령어 이름  (mov / add / loop ...)
;    · 피연산자 : 0~3개, 첫 번째 = 목적지, 두 번째 = 소스

.386                            ; 32비트 IA-32 명령어 집합 선언
.MODEL flat, stdcall            ; 단일 평면 메모리 / Windows 호출 규약
.STACK 4096                     ; 런타임 스택 4096바이트 예약

ExitProcess PROTO, dwExitCode:DWORD  ; Windows 종료 서비스 프로토타입

; ══════════════════════════════════════════════════════════════════
; [CH3-2]  데이터 타입 & 리틀 엔디안 ★ 시험 단골 ★
; ══════════════════════════════════════════════════════════════════
;
;  내장 데이터 타입 전체 표:
;  ┌──────────┬──────┬──────────────────────────────────────────┐
;  │ 타입     │ 크기 │ 범위                                     │
;  ├──────────┼──────┼──────────────────────────────────────────┤
;  │ BYTE     │ 1B   │ 0 ~ 255                                  │
;  │ SBYTE    │ 1B   │ -128 ~ 127           ← 시험 자주 출제!  │
;  │ WORD     │ 2B   │ 0 ~ 65,535                               │
;  │ SWORD    │ 2B   │ -32,768 ~ 32,767                         │
;  │ DWORD    │ 4B   │ 0 ~ 4,294,967,295                        │
;  │ SDWORD   │ 4B   │ -2,147,483,648 ~ 2,147,483,647           │
;  │ QWORD    │ 8B   │ 64비트 정수                              │
;  │ REAL4    │ 4B   │ IEEE 754 단정밀도                        │
;  │ REAL8    │ 8B   │ IEEE 754 배정밀도                        │
;  └──────────┴──────┴──────────────────────────────────────────┘
;  레거시: DB=BYTE  DW=WORD  DD=DWORD/REAL4  DQ=QWORD/REAL8
;
;  ★ 리틀 엔디안 (Little-Endian) — x86의 다중 바이트 저장 방식 ★
;    최하위 바이트(LSB)를 가장 낮은 주소에 먼저 저장
;
;    예) DWORD 12345678h 를 주소 100h에 저장:
;      주소 100h: 78h  ← LSB (최하위 바이트) 먼저
;      주소 101h: 56h
;      주소 102h: 34h
;      주소 103h: 12h  ← MSB (최상위 바이트) 나중
;
;    예) WORD 0AB12h, 0CD34h 두 개를 순서대로 저장:
;      +0: 12h  +1: ABh  +2: 34h  +3: CDh

.DATA
    ; ── 기본 변수 선언 ──────────────────────────────────────────
    val1    BYTE    10h             ; 1바이트, 값 = 16
    sval    SBYTE   -128            ; 부호 있는 8비트 최솟값
    wval    WORD    1000h           ; 2바이트
    dval    DWORD   12345678h       ; 4바이트 (리틀 엔디안으로 78 56 34 12)
    undef   DWORD   ?               ; 미초기화 (런타임에 값 불확실)

    ; ── 배열 선언 ────────────────────────────────────────────────
    ; 여러 초기값 → 연속 메모리 할당, 레이블은 첫 번째 원소 주소
    byteArr BYTE    10h, 20h, 30h, 40h, 50h    ; 5바이트 배열
            BYTE    60h, 70h                    ; 레이블 없이 이어서 추가 가능
    wordArr WORD    100h, 200h, 300h, 400h      ; 4워드 = 8바이트
    dwordArr DWORD  1000h, 2000h, 3000h         ; 3더블워드 = 12바이트

    ; ── 문자 / 문자열 ────────────────────────────────────────────
    charA   BYTE    'A'             ; ASCII 41h = 65
    str1    BYTE    "Hello", 0      ; 널 종료 문자열 (6바이트)
    crlf    BYTE    0Dh, 0Ah, 0     ; CR+LF (줄바꿈 시퀀스)

    ; ── 실수형 ────────────────────────────────────────────────────
    r4val   REAL4   3.14
    r8val   REAL8   3.141592653589793

    ; ── 리틀 엔디안 확인용 ───────────────────────────────────────
    leDemo  DWORD   12345678h       ; 메모리: [78][56][34][12]
    ; WORD 0AB12h, 0CD34h 연달아 저장시: [12][AB][34][CD]
    leWord1 WORD    0AB12h          ; 메모리: [12][AB]
    leWord2 WORD    0CD34h          ; 메모리: [34][CD]


; ══════════════════════════════════════════════════════════════════
; [CH3-3]  DUP 연산자 / .DATA? / 코드-데이터 혼합
; ══════════════════════════════════════════════════════════════════
;
;  DUP 연산자:  횟수 DUP(초기값)
;    BYTE  10  DUP(0)      → 0이 10개 (10바이트)
;    BYTE  5   DUP(?)      → 미초기화 5바이트
;    WORD  8   DUP(0)      → 0인 WORD 8개 (16바이트)
;    BYTE  2   DUP(3 DUP(0FFh))  → 중첩 DUP: FF×6
;
;  .DATA?  → 실행 파일 크기를 줄이는 미초기화 세그먼트
;    .DATA   bigBuf BYTE 10000 DUP(0)  → 파일에 0이 10000바이트 포함
;    .DATA?  bigBuf BYTE 10000 DUP(?)  → 파일에 크기 정보만 기록 (절약!)

    dupDemo BYTE    5  DUP(0FFh)    ; FF FF FF FF FF (5바이트)
    zBuf    BYTE    10 DUP(0)       ; 0으로 초기화된 버퍼
    result  DWORD   ?               ; 미초기화 결과 변수

.DATA?
    bigBuf  BYTE    4096 DUP(?)     ; 실행 파일 크기에 영향 없음


; ══════════════════════════════════════════════════════════════════
; [CH3-4]  심볼릭 상수 — = / $ / EQU / TEXTEQU ★ 비교표 암기 ★
; ══════════════════════════════════════════════════════════════════
;
;  ┌────────────┬────────────────┬──────────┬──────────────────────┐
;  │ 디렉티브   │ 값의 종류      │ 재정의   │ 특징                 │
;  ├────────────┼────────────────┼──────────┼──────────────────────┤
;  │ =          │ 정수 표현식만  │ 가능 ✓   │ 어셈블 시간 상수     │
;  │ EQU        │ 정수 또는 텍스트│ 불가 ✗  │ 텍스트 포함 가능     │
;  │ TEXTEQU    │ 텍스트만       │ 가능 ✓   │ 텍스트 매크로        │
;  └────────────┴────────────────┴──────────┴──────────────────────┘
;
;  ☑ 퀴즈: 아래 중 오류가 발생하는 줄은?
;    COUNT = 10
;    COUNT = 20          ; (A) → 합법! = 은 재정의 가능
;    SIZE EQU 50
;    SIZE EQU 100        ; (B) → 오류! EQU는 재정의 불가
;    MSG TEXTEQU <"Hi">
;    MSG TEXTEQU <"Bye"> ; (C) → 합법! TEXTEQU는 재정의 가능

; -- 등호(=) 디렉티브 --
COUNT       = 10                ; 정수 심볼 정의
LIMIT       = COUNT * 4         ; 수식 사용 가능 (= 40)
LIMIT       = 200               ; 재정의 가능 (합법)

; -- $ 연산자 (현재 위치 카운터) --
;   $ = 현재 오프셋,  배열 바로 뒤에 배치하면 배열 크기 자동 계산
list        BYTE    10, 20, 30, 40, 50
ListSize    = ($ - list)            ; = 5 (바이트 5개)

wList       WORD    100, 200, 300
wListSize   = ($ - wList) / 2      ; = 3 (WORD = 2바이트이므로 /2)

dList       DWORD   1000, 2000, 3000
dListSize   = ($ - dList) / 4      ; = 3 (DWORD = 4바이트이므로 /4)

; -- EQU 디렉티브 --
ROWS        EQU 5
COLS        EQU 10
MATRIX_SIZE EQU ROWS * COLS         ; = 50 (정수 표현식)
PI          EQU <3.14159>           ; 텍스트 (정수 아님)
PressKey    EQU <"Press any key",0>  ; 텍스트 EQU
; ROWS EQU 999  ← 이걸 해제하면 어셈블 오류 (EQU 재정의 금지)

; -- TEXTEQU 디렉티브 --
moveVal     TEXTEQU <mov eax>       ; 텍스트 매크로
count5      TEXTEQU %(ROWS)         ; 정수 → 텍스트 변환 (= "5")
myMsg       TEXTEQU <"Hello",0>
myMsg       TEXTEQU <"Updated",0>   ; 재정의 가능

    sysBuf  BYTE    myMsg           ; TEXTEQU 확장 → BYTE "Updated",0


; ══════════════════════════════════════════════════════════════════
; [CH4-1]  MOV 규칙 & 겹치는 레지스터 ★ 시험 단골 ★
; ══════════════════════════════════════════════════════════════════
;
;  MOV 규칙 (위반 시 어셈블 오류):
;  ┌──────────────────────────────────────────┬────────┐
;  │ 조합                                     │ 가능?  │
;  ├──────────────────────────────────────────┼────────┤
;  │ MOV reg, imm    (즉치 → 레지스터)        │  ✓     │
;  │ MOV reg, reg    (레지스터 → 레지스터)    │  ✓     │
;  │ MOV reg, mem    (메모리 → 레지스터)      │  ✓     │
;  │ MOV mem, reg    (레지스터 → 메모리)      │  ✓     │
;  │ MOV mem, imm    (즉치 → 메모리)          │  ✓     │
;  │ MOV mem, mem    (메모리 → 메모리)        │  ✗ 불가│
;  │ MOV reg(다른크기), reg                   │  ✗ 불가│
;  │ MOV EIP, reg    (EIP는 목적지 불가)      │  ✗ 불가│
;  │ MOV DS, imm     (세그먼트에 즉치 불가)   │  ✗ 불가│
;  └──────────────────────────────────────────┴────────┘
;
;  겹치는 레지스터:
;    EAX(32) ⊃ AX(16) ⊃ AH(8, 상위) / AL(8, 하위)
;    작은 서브레지스터를 써도 나머지 비트는 그대로!
;    예) EAX = 12345678h → MOV AL, 0AAh → EAX = 123456AAh

    xval    WORD    1234h
    yval    WORD    5678h
    var3    DWORD   0ABCD1234h


.CODE
main PROC

    ; ── MOV 기본 예제 ────────────────────────────────────────────
    mov eax, 10             ; [즉치 → 레지스터]  EAX = 10
    mov ebx, eax            ; [레지스터 → 레지스터] EBX = EAX
    mov al, val1            ; [메모리 → 레지스터]  AL = 10h
    mov val1, al            ; [레지스터 → 메모리]  val1 = AL

    ; 메모리→메모리는 불가 → 레지스터 경유
    ; mov var3, leDemo      ← 오류!
    mov eax, leDemo
    mov var3, eax           ; 올바른 방법

    ; ── 겹치는 레지스터 예제 ─────────────────────────────────────
    mov eax, 12345678h      ; EAX = 12345678h
    mov al, 0AAh            ; EAX = 123456AAh (상위 3바이트 유지)
    mov ax, 0BBBBh          ; EAX = 1234BBBBh (상위 2바이트 유지)
    mov ax, 0               ; EAX = 12340000h (상위 유지, 하위 16비트 클리어)


; ══════════════════════════════════════════════════════════════════
; [CH4-2]  MOVZX / MOVSX — 크기 불일치 해결 ★ 시험 단골 ★
; ══════════════════════════════════════════════════════════════════
;
;  MOV는 크기가 다른 피연산자 간에 사용 불가!
;  → 작은 → 큰 복사: MOVZX (부호 없는 값) 또는 MOVSX (부호 있는 값)
;
;  MOVZX (Zero-Extend): 상위 비트를 0으로 채움
;    부호 없는 정수에 사용
;    BL = 0A0h → movzx eax, bl → EAX = 000000A0h (+160, 올바름)
;
;  MOVSX (Sign-Extend): 상위 비트를 소스의 MSB(부호 비트)로 채움
;    부호 있는 정수에 사용
;    BL = 0A0h (-96) → movsx eax, bl → EAX = FFFFFFA0h (-96, 올바름)
;
;  ☑ 퀴즈: BL = F0h 일 때 각 명령 후 EAX?
;    movzx eax, bl → EAX = 000000F0h (+240)
;    movsx eax, bl → EAX = FFFFFFF0h (-16)

    ; ── MOVZX 예제 ───────────────────────────────────────────────
    mov bl, 0A0h
    movzx eax, bl           ; EAX = 000000A0h (상위 비트 0으로 채움)
    movzx ax, val1          ; AX  = 0010h     (8→16비트)
    movzx eax, val1         ; EAX = 00000010h (8→32비트)
    movzx eax, wval         ; EAX = 00001000h (16→32비트)

    ; ── MOVSX 예제 ───────────────────────────────────────────────
    mov bl, 0F0h            ; BL = F0h = -16 (부호 있는 해석)
    movsx eax, bl           ; EAX = FFFFFFF0h (-16, 부호 비트=1이므로 상위=FF)
    movsx ax, bl            ; AX  = FFF0h

    ; 양수 값은 MOVZX와 동일 결과
    mov bl, 05h             ; BL = 05h = +5
    movsx eax, bl           ; EAX = 00000005h (부호 비트=0이므로 상위=00)


; ══════════════════════════════════════════════════════════════════
; [CH4-3]  INC / DEC / ADD / SUB / NEG & CPU 플래그 ★ 핵심 ★
; ══════════════════════════════════════════════════════════════════
;
;  CPU 플래그 총정리:
;  ┌─────┬────────────────────────────────────────────────────────┐
;  │ CF  │ 부호 없는 오버플로: MSB에서 올림(Carry out) 발생      │
;  │ OF  │ 부호 있는 오버플로: 양+양=음 또는 음+음=양            │
;  │ ZF  │ 결과 = 0                                              │
;  │ SF  │ 결과의 MSB = 1 (음수)                                 │
;  │ PF  │ 결과 하위 바이트의 1비트 개수가 짝수                  │
;  │ AF  │ 비트 3→4 올림 (BCD 연산용)                           │
;  └─────┴────────────────────────────────────────────────────────┘
;
;  ★ INC/DEC는 CF에 영향을 주지 않음! (시험 자주 출제)
;
;  OF 판정 규칙 (8비트 예):
;    · 양수(+) + 양수(+) = 음수 MSB(1)  →  OF = 1
;    · 음수(-) + 음수(-) = 양수 MSB(0)  →  OF = 1
;    · 양수 + 음수 (반대 부호)          →  OF = 0 (절대)
;
;  ☑ 퀴즈: AL=127(7Fh) → add al, 1 → AL=80h=-128 → OF=1, CF=0
;  ☑ 퀴즈: AL=0FFh    → add al, 1 → AL=0         → CF=1, ZF=1, OF=0

    ; ── INC / DEC ────────────────────────────────────────────────
    mov eax, 5
    inc eax                 ; EAX = 6 (CF 변화 없음!)
    dec eax                 ; EAX = 5

    mov al, 0FFh
    inc al                  ; AL = 0, ZF=1, OF=1 (BYTE 오버플로)
                            ; ★ CF는 여전히 변화 없음

    ; ── ADD / SUB ────────────────────────────────────────────────
    mov al, 0FFh
    add al, 1               ; AL = 0, CF = 1 (부호없는 오버플로)
                            ;        ZF = 1 (결과 = 0)
                            ;        OF = 0 (부호있는 관점: -1+1=0, 정상)

    mov al, 127             ; AL = 7Fh
    add al, 1               ; AL = 80h = -128, OF = 1 (부호있는 오버플로!)
                            ; 양수+양수=음수

    mov al, 10
    sub al, 20              ; AL = -10 (= 246 = F6h), CF = 1 (언더플로)

    ; ── NEG (부호 반전, 2의 보수) ────────────────────────────────
    ; 2의 보수 = 비트 전체 반전 + 1
    ; 0이 아닌 값에 NEG → CF = 1 (항상)
    ; SBYTE -128에 NEG  → 결과 -128, OF = 1 (오버플로!)
    mov eax, -24
    neg eax                 ; EAX = +24, CF = 1

    mov eax, 0
    neg eax                 ; EAX = 0, CF = 0, ZF = 1

    ; ── 산술 표현식 구현: rval = -Xval + (Yval - Zval) ──────────
    ; Xval=26, Yval=30, Zval=40 → rval = -26 + (-10) = -36
    .DATA
        Xval SDWORD 26
        Yval SDWORD 30
        Zval SDWORD 40
        rval SDWORD 0
    .CODE
    mov eax, Xval           ; EAX = 26
    neg eax                 ; EAX = -26
    mov ebx, Yval           ; EBX = 30
    sub ebx, Zval           ; EBX = 30 - 40 = -10
    add eax, ebx            ; EAX = -26 + (-10) = -36
    mov rval, eax           ; rval = -36

    ; ── LAHF / SAHF — 플래그 백업/복원 ──────────────────────────
    lahf                    ; AH = EFLAGS 하위 8비트 (SF,ZF,AF,PF,CF)
    ; (다른 연산 수행)
    sahf                    ; AH의 값을 EFLAGS에 복원

    ; ── XCHG — 두 피연산자 값 교환 (즉치 불가) ──────────────────
    mov eax, 1111h
    mov ebx, 2222h
    xchg eax, ebx           ; EAX=2222h, EBX=1111h

    ; 두 메모리 변수 교환 (XCHG는 메모리-메모리 불가)
    mov ax, xval
    xchg ax, yval           ; AX ↔ yval
    mov xval, ax


; ══════════════════════════════════════════════════════════════════
; [CH4-4]  OFFSET / ALIGN / PTR / TYPE / LENGTHOF / SIZEOF / LABEL
; ══════════════════════════════════════════════════════════════════
;
;  연산자/디렉티브 요약 (어셈블 시간에 평가):
;
;  OFFSET   → 변수의 세그먼트 시작 기준 바이트 오프셋(주소) 반환
;             예) mov esi, OFFSET myArray   ; ESI = myArray 주소
;
;  ALIGN n  → 다음 변수를 n바이트 경계에 정렬 (n: 1,2,4,8,16)
;             CPU는 정렬된 데이터를 더 빠르게 처리
;
;  PTR      → 선언된 크기를 재정의, 다른 크기로 메모리 접근
;             예) DWORD 12345678h → BYTE PTR myD = 78h (리틀 엔디안!)
;
;  TYPE     → 변수 한 원소의 크기(바이트)
;  LENGTHOF → 배열의 원소 개수 (첫 번째 선언 줄만 카운트)
;  SIZEOF   → 배열 전체 바이트 수 = LENGTHOF × TYPE
;
;  ┌──────────────────────────────────────────────────────────────┐
;  │ 선언                    TYPE  LENGTHOF  SIZEOF              │
;  ├──────────────────────────────────────────────────────────────┤
;  │ arr BYTE  10,20,30       1     3         3                  │
;  │ arr WORD  10,20,30       2     3         6                  │
;  │ arr DWORD 10,20,30       4     3         12                 │
;  └──────────────────────────────────────────────────────────────┘
;  ☑ 퀴즈: arr DWORD 1,2,3,4,5 → TYPE=4, LENGTHOF=5, SIZEOF=20

    ; ── OFFSET 사용 ──────────────────────────────────────────────
    mov esi, OFFSET byteArr     ; ESI = byteArr의 메모리 주소
    mov al, [esi]               ; AL = byteArr[0] = 10h (간접 접근)

    ; ── PTR 사용 (리틀 엔디안 이해 필수) ────────────────────────
    ; dval = 12345678h, 메모리: [78][56][34][12] (낮은→높은 주소)
    mov ax, WORD PTR dval       ; AX = 5678h (하위 워드)
    mov al, BYTE PTR dval       ; AL = 78h   (최하위 바이트)
    mov al, BYTE PTR [dval+1]   ; AL = 56h   (두 번째 바이트)
    mov al, BYTE PTR [dval+3]   ; AL = 12h   (최상위 바이트)
    movzx eax, WORD PTR dval    ; EAX = 00005678h (제로 확장)

    ; ── TYPE / LENGTHOF / SIZEOF ─────────────────────────────────
    ; TYPE byteArr  = 1,  LENGTHOF byteArr  = 5,  SIZEOF byteArr  = 5
    ; TYPE wordArr  = 2,  LENGTHOF wordArr  = 4,  SIZEOF wordArr  = 8
    ; TYPE dwordArr = 4,  LENGTHOF dwordArr = 3,  SIZEOF dwordArr = 12

    mov ecx, LENGTHOF dwordArr  ; ECX = 3 (루프 카운터로 활용)
    mov esi, OFFSET dwordArr
    mov eax, 0
typeLoop:
    add eax, [esi]
    add esi, TYPE dwordArr      ; TYPE 연산자로 원소 크기 자동 적용
    loop typeLoop               ; EAX = 1000h+2000h+3000h = 6000h

    ; ── LABEL 디렉티브 — 같은 주소를 다른 크기로 접근하는 별칭 ──
    .DATA
        val16 LABEL WORD        ; 스토리지 미할당, WORD 별칭 생성
        val32 DWORD 0ABCD1234h  ; 실제 4바이트 저장소 (val16과 같은 주소)
    .CODE
    mov ax, val16               ; AX = 1234h (하위 WORD, 리틀 엔디안)
    mov eax, val32              ; EAX = 0ABCD1234h (전체 DWORD)

    ; ── ALIGN 디렉티브 (데이터 선언 시 사용) ────────────────────
    ; .DATA 에서 사용하는 예:
    ;   bAlign BYTE 'X'
    ;   ALIGN 4         ← 다음 변수를 4바이트 경계로 정렬 (패딩 자동 삽입)
    ;   dAlign DWORD 0  ← 4바이트 경계에 배치


; ══════════════════════════════════════════════════════════════════
; [CH4-5]  간접 주소지정 & 인덱스 피연산자 & 스케일 팩터
; ══════════════════════════════════════════════════════════════════
;
;  직접(Direct)   : mov al, myVar      (주소 고정, 컴파일 시 결정)
;  간접(Indirect) : mov esi, OFFSET arr / mov al, [esi]  (배열 순회에 유용)
;
;  ★ 배열 순회 시 ESI 증가량:
;    BYTE  배열 → add esi, 1 (또는 inc esi)
;    WORD  배열 → add esi, 2
;    DWORD 배열 → add esi, 4
;    일반화:      add esi, TYPE 배열이름
;
;  인덱스 피연산자 두 가지 표기:
;    형식A: [byteArr + esi]   또는   byteArr[esi]
;    형식B: [esi + 2]   (레지스터 = 배열 시작, 상수 = 오프셋)
;
;  스케일 팩터: [배열 + 인덱스 * 스케일]  (WORD=2, DWORD=4, QWORD=8)
;    mov esi, 2
;    mov eax, [dwordArr + esi * 4]  ; dwordArr[2], 바이트오프셋=8

    ; ── 간접 피연산자 ────────────────────────────────────────────
    mov esi, OFFSET byteArr     ; ESI = 배열 시작 주소
    mov al, [esi]               ; AL = byteArr[0] = 10h
    mov bl, 0BBh
    mov [esi], bl               ; byteArr[0] = BBh (쓰기도 가능)

    ; 크기 불명확 시 PTR 필수
    ; inc [esi]              ← 오류! 크기 불명확
    inc BYTE PTR [esi]          ; 올바름: BYTE로 명시
    inc DWORD PTR [esi]         ; DWORD로도 접근 가능 (같은 주소, 다른 크기)

    ; ── BYTE 배열 순회 ───────────────────────────────────────────
    mov esi, OFFSET byteArr
    mov al, [esi]               ; byteArr[0]
    inc esi
    mov al, [esi]               ; byteArr[1]
    inc esi
    mov al, [esi]               ; byteArr[2]

    ; ── WORD 배열 순회 ───────────────────────────────────────────
    mov esi, OFFSET wordArr
    mov ax, [esi]               ; wordArr[0] = 100h
    add esi, 2                  ; 다음 WORD (+2바이트)
    mov ax, [esi]               ; wordArr[1] = 200h

    ; ── DWORD 배열 순회 ──────────────────────────────────────────
    mov esi, OFFSET dwordArr
    mov eax, [esi]              ; dwordArr[0] = 1000h
    add esi, 4                  ; 다음 DWORD (+4바이트)
    mov eax, [esi]              ; dwordArr[1] = 2000h

    ; ── 인덱스 피연산자 (형식A: 배열+레지스터) ────────────────────
    mov esi, 0
    mov al, byteArr[esi]        ; byteArr[0]
    mov al, [byteArr + esi]     ; 위와 동일
    inc esi
    mov al, [byteArr + esi]     ; byteArr[1]

    ; ── 인덱스 피연산자 (형식B: 레지스터+상수) ────────────────────
    mov esi, OFFSET byteArr     ; ESI = 배열 시작
    mov al, [esi]               ; [0]
    mov al, [esi + 1]           ; [1]
    mov al, [esi + 4]           ; [4]

    ; ── 스케일 팩터 ──────────────────────────────────────────────
    mov esi, 2
    mov eax, [dwordArr + esi * 4]   ; dwordArr[2] = 3000h

    mov esi, 1
    mov ax, [wordArr + esi * 2]     ; wordArr[1] = 200h

    ; ── 포인터 변수 ──────────────────────────────────────────────
    .DATA
        arrayB  BYTE  10h, 20h, 30h
        ptrB    DWORD OFFSET arrayB  ; arrayB의 주소를 저장
    .CODE
    mov esi, ptrB               ; ESI = arrayB의 주소 (포인터 역참조)
    mov al, [esi]               ; AL = arrayB[0] = 10h
    inc esi
    mov al, [esi]               ; AL = arrayB[1] = 20h


; ══════════════════════════════════════════════════════════════════
; [CH4-6]  JMP / LOOP — 배열 합산 & 문자열 복사 ★ 시험 단골 ★
; ══════════════════════════════════════════════════════════════════
;
;  JMP 레이블 → 무조건 EIP = 목적지 (단독으로는 무한루프)
;
;  LOOP 레이블:
;    ① ECX -= 1
;    ② ECX ≠ 0 이면 레이블로 점프 (계속)
;       ECX = 0 이면 다음 명령어로 (종료)
;  ★ 치명적 실수: ECX = 0으로 시작하면 ECX -= 1 = FFFFFFFFh (42억 회!)
;
;  배열 합산 7단계 패턴:
;    ① mov esi, OFFSET 배열         ← 배열 주소
;    ② mov ecx, LENGTHOF 배열       ← 루프 카운터
;    ③ mov eax, 0                   ← 누적 합 초기화
;    ④ (루프 레이블):
;    ⑤ add eax, [esi]               ← 원소 누적
;    ⑥ add esi, TYPE 배열           ← 다음 원소
;    ⑦ loop (루프 레이블)

    .DATA
        intArray  DWORD 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
        arraySum  DWORD 0
        source    BYTE  "Hello, Assembly!", 0
        target    BYTE  SIZEOF source DUP(0)
    .CODE

    ; ── JMP 기본 ─────────────────────────────────────────────────
    jmp skipSection         ; 아래 코드를 건너뜀
    mov eax, 0FFFFFFFFh     ; 실행되지 않는 코드
skipSection:
    mov eax, 0

    ; ── LOOP 기본 ────────────────────────────────────────────────
    mov ecx, 5              ; 5회 반복
    mov eax, 0
loopDemo:
    add eax, ecx            ; EAX += 5, 4, 3, 2, 1
    loop loopDemo           ; ECX-- ; 0되면 탈출
    ; 결과: EAX = 15 (1+2+3+4+5)

    ; ── 중첩 루프 (외부 ECX 변수에 백업) ────────────────────────
    .DATA
        outerCnt DWORD 0
    .CODE
    mov ecx, 3
outerLoop:
    mov outerCnt, ecx       ; 외부 ECX 백업
    mov ecx, 5
innerLoop:
    nop
    loop innerLoop          ; 내부 루프 5회
    mov ecx, outerCnt       ; 외부 ECX 복원
    loop outerLoop          ; 외부 루프 3회 → 총 15회 실행

    ; ── 배열 합산 패턴 (7단계) ───────────────────────────────────
    mov esi, OFFSET intArray        ; ① 배열 주소
    mov ecx, LENGTHOF intArray      ; ② 루프 카운터 = 10
    mov eax, 0                      ; ③ 누적 합 초기화
sumLoop:
    add eax, [esi]                  ; ⑤ 현재 원소 누적
    add esi, TYPE intArray          ; ⑥ 다음 원소 (DWORD = 4바이트)
    loop sumLoop                    ; ⑦ ECX-- ; 반복
    mov arraySum, eax               ; arraySum = 55

    ; ── 문자열 복사 패턴 (AL 경유 — 메모리↔메모리 직접 불가) ─────
    mov esi, 0
    mov ecx, SIZEOF source          ; 널 문자 포함 전체 바이트
copyLoop:
    mov al, source[esi]             ; AL = source[i]
    mov target[esi], al             ; target[i] = AL
    inc esi
    loop copyLoop                   ; 모든 바이트 복사 완료


; ══════════════════════════════════════════════════════════════════
; [CH5-1]  런타임 스택 — PUSH / POP / PUSHFD / PUSHAD
; ══════════════════════════════════════════════════════════════════
;
;  스택 핵심 개념:
;    · LIFO (Last-In, First-Out)
;    · 높은 주소 → 낮은 주소 방향으로 성장 (top이 낮은 주소)
;    · ESP(Extended Stack Pointer)가 스택의 최상단(top)을 가리킴
;
;  PUSH 동작 (32비트 기준):
;    ① ESP -= 4
;    ② [ESP] = 값
;
;  POP 동작 (32비트 기준):
;    ① 목적지 = [ESP]
;    ② ESP += 4
;    ※ POP은 메모리를 지우지 않음. ESP만 이동.
;
;  스택 활용 4가지 용도 (시험 자주 출제!):
;    ① 레지스터 임시 보존
;    ② CALL 명령어의 복귀 주소 저장
;    ③ 프로시저에 인수(argument) 전달
;    ④ 프로시저 내 지역 변수 저장
;
;  ☑ 퀴즈: 다음 실행 후 EAX, EBX는?
;    push 10
;    push 20
;    pop  eax   ; EAX = 20 (LIFO)
;    pop  ebx   ; EBX = 10
;
;  ☑ 퀴즈: 아래 코드의 버그는?
;    push eax
;    push ebx
;    pop  eax   ; ← ebx 값이 eax로 들어옴 (순서 역전!)
;    pop  ebx   ; ← eax 값이 ebx로 들어옴
;    → POP 순서는 반드시 PUSH의 역순이어야 함

    ; ── PUSH / POP 기본 ──────────────────────────────────────────
    push 10h                ; ESP -= 4, [ESP] = 10h
    push 20h                ; ESP -= 4, [ESP] = 20h
    push 30h                ; ESP -= 4, [ESP] = 30h
    pop  eax                ; EAX = 30h, ESP += 4
    pop  ebx                ; EBX = 20h, ESP += 4
    pop  ecx                ; ECX = 10h, ESP += 4

    ; ── 레지스터 보존 패턴 ───────────────────────────────────────
    push eax                ; EAX 보존
    push ebx                ; EBX 보존
    mov  eax, 9999
    mov  ebx, 8888
    pop  ebx                ; EBX 복원 (PUSH 역순!)
    pop  eax                ; EAX 복원

    ; ── PUSHFD / POPFD — EFLAGS 보존 ────────────────────────────
    ; MOV로는 EFLAGS를 직접 읽거나 쓸 수 없음 → PUSHFD/POPFD 필수
    pushfd                  ; EFLAGS(32비트) 전체 → 스택
    mov  al, 0FFh
    add  al, 1              ; 플래그 변경
    popfd                   ; 원래 EFLAGS 복원

    ; 변수에 저장하는 패턴:
    .DATA
        savedFlags DWORD 0
    .CODE
    pushfd
    pop  savedFlags         ; EFLAGS → 변수
    ; (작업 수행)
    push savedFlags         ; 변수 → 스택
    popfd                   ; EFLAGS 복원

    ; ── PUSHAD / POPAD — 8개 범용 레지스터 일괄 저장/복원 ────────
    ; PUSHAD 순서: EAX, ECX, EDX, EBX, ESP*, EBP, ESI, EDI
    ; POPAD  순서: 위 역순으로 POP
    ; ★ 반환값이 EAX인 프로시저에서 POPAD 금지! (EAX가 덮어써짐)
    pushad                  ; 8개 레지스터 → 스택
    mov  eax, 1111h
    mov  ebx, 2222h
    popad                   ; 스택 → 8개 레지스터 (원상복구)


; ══════════════════════════════════════════════════════════════════
; [CH5-2]  스택 응용 — 문자열 뒤집기 ("ABCDE" → "EDCBA")
; ══════════════════════════════════════════════════════════════════
;
;  알고리즘:
;    1단계: 문자열을 앞에서부터 PUSH → 스택 top에 마지막 문자
;    2단계: 스택에서 POP하며 원래 배열에 덮어씀 → 역순이 됨
;
;    "ABCDE" push 순서: A, B, C, D, E
;    스택 top: E / D / C / B / A
;    pop 순서: E, D, C, B, A → "EDCBA"

    .DATA
        myStr   BYTE "ABCDE", 0
        strLen  = 5
    .CODE

    ; 1단계: PUSH (앞→뒤 순으로)
    mov ecx, strLen
    mov esi, 0
pushLoop:
    movzx eax, myStr[esi]   ; AL = myStr[i], 상위 비트 클리어
    push  eax               ; 문자를 스택에 저장
    inc   esi
    loop  pushLoop

    ; 2단계: POP (역순으로 꺼내 덮어쓰기)
    mov ecx, strLen
    mov esi, 0
popLoop:
    pop   eax               ; top에서 꺼냄 (E, D, C, B, A 순)
    mov   myStr[esi], al    ; 원래 위치에 덮어씀
    inc   esi
    loop  popLoop
    ; 결과: myStr = "EDCBA\0"


; ══════════════════════════════════════════════════════════════════
; [CH5-3]  CALL / RET & 프로시저 정의 ★ 시험 단골 ★
; ══════════════════════════════════════════════════════════════════
;
;  CALL 명령어 동작 (2단계):
;    ① ESP -= 4
;    ② [ESP] = CALL 다음 명령어 주소 (복귀 주소)
;    ③ EIP = 피호출 프로시저 시작 주소
;
;  RET 명령어 동작 (CALL의 역순):
;    ① EIP = [ESP]  (복귀 주소 POP)
;    ② ESP += 4
;
;  ☑ 퀴즈: CALL 전 ESP = 0000FF00h 라면 CALL 직후 ESP = ?
;    → ESP = 0000FEFCh (= FF00h - 4)
;    → [ESP] = CALL 다음 명령어 주소 (복귀 주소)
;    → EIP = 피호출 함수 시작 주소
;
;  프로시저 기본 구조:
;    이름 PROC
;        ...
;        ret
;    이름 ENDP
;
;  레이블 범위:
;    기본: 선언된 프로시저 내에서만 유효
;    전역: 이름:: (콜론 두 개) → 다른 프로시저에서도 JMP 가능

    ; ── SumOfThree 호출 ──────────────────────────────────────────
    mov  eax, 10            ; 첫 번째 인수
    mov  ebx, 20            ; 두 번째 인수
    mov  ecx, 30            ; 세 번째 인수
    call SumOfThree         ; EAX = 10 + 20 + 30 = 60
    ; CALL 실행 직후: [ESP] = 복귀 주소, EIP = SumOfThree 시작

    ; ── ArraySum 호출 ────────────────────────────────────────────
    .DATA
        intArr2 DWORD 10, 20, 30, 40, 50
        theSum  DWORD ?
    .CODE
    mov  esi, OFFSET intArr2
    mov  ecx, LENGTHOF intArr2
    call ArraySum           ; EAX = 150
    mov  theSum, eax

    ; ── 중첩 호출 ────────────────────────────────────────────────
    call Sub1               ; main → Sub1 → Sub2 → (복귀) → Sub1 → main

    INVOKE ExitProcess, 0
main ENDP


; ══════════════════════════════════════════════════════════════════
; [CH5-3] 프로시저 정의 예제 — 실제 코드
; ══════════════════════════════════════════════════════════════════

; ① SumOfThree — 세 정수 합산 (EAX = EAX + EBX + ECX)
;   Receives: EAX, EBX, ECX
;   Returns : EAX = 합계
SumOfThree PROC
    add eax, ebx            ; EAX = EAX + EBX
    add eax, ecx            ; EAX = EAX + EBX + ECX
    ret                     ; 복귀 주소 POP → EIP = main의 다음 명령어
SumOfThree ENDP


; ══════════════════════════════════════════════════════════════════
; [CH5-4]  ArraySum & USES 연산자 ★ USES 함정 주의 ★
; ══════════════════════════════════════════════════════════════════
;
;  USES 연산자:
;    이름 PROC USES reg1 reg2 ...
;    · 프로시저 시작 시 자동 PUSH, 종료 시 자동 POP 코드를 어셈블러가 삽입
;    · ★ 반환값 레지스터(보통 EAX)를 USES에 넣으면 안 됨!
;      이유: RET 직전에 pop eax가 삽입되어 반환값을 덮어씀
;
;  ☑ 퀴즈: 다음 코드의 문제점은?
;    BadProc PROC USES eax
;        mov eax, 42   ; 반환값 설정
;        ret           ; USES가 pop eax 삽입 → EAX = 원래 값으로 덮어써짐!
;    BadProc ENDP
;    → 해결: USES 목록에서 EAX를 제거

; ② ArraySum — 배열 합산 (수동 PUSH/POP으로 레지스터 보존)
;   Receives: ESI = 배열 시작 주소, ECX = 원소 개수
;   Returns : EAX = 합계
ArraySum PROC
    push esi                ; 호출자의 ESI 보존
    push ecx                ; 호출자의 ECX 보존
    mov  eax, 0             ; 누적 합 초기화
sumL:
    add  eax, [esi]         ; EAX += [ESI]
    add  esi, 4             ; 다음 DWORD 원소
    loop sumL               ; ECX-- ; 반복
    pop  ecx                ; ECX 복원 (역순!)
    pop  esi                ; ESI 복원
    ret
ArraySum ENDP

; ③ ArraySumUSES — USES로 자동 보존 (위와 동일 동작)
ArraySumUSES PROC USES esi ecx  ; 어셈블러가 push/pop 자동 삽입
    mov  eax, 0
sumLU:
    add  eax, [esi]
    add  esi, 4
    loop sumLU
    ret                     ; pop ecx / pop esi 자동 삽입 후 복귀
ArraySumUSES ENDP


; ══════════════════════════════════════════════════════════════════
; [CH5-5]  중첩 호출 & 전역 레이블
; ══════════════════════════════════════════════════════════════════
;
;  중첩 호출 (Nested Calls):
;    main → Sub1 → Sub2
;    · CALL마다 복귀 주소가 스택에 쌓임
;    · RET마다 역순으로 꺼내서 복귀 (LIFO)
;    · 스택이 올바른 복귀 순서를 자동 보장
;
;  전역 레이블:
;    기본 레이블 : 선언된 프로시저 내에서만 유효
;    전역 레이블 : 이름:: (콜론 두 개) → 파일 어디서든 JMP 가능
;    예) TargetLabel::   (주의: 외부 JMP는 스택 정합성 깨뜨릴 수 있음)

; ④ Sub2
Sub2 PROC
    mov ecx, 10             ; Sub2의 작업
    ret                     ; Sub1의 CALL Sub2 다음 명령어로 복귀
Sub2 ENDP

; ⑤ Sub1 (Sub2 호출)
Sub1 PROC
    push eax                ; EAX 보존
    call Sub2               ; Sub2 호출 → 복귀 주소(Sub1 내)가 스택에 PUSH
    pop  eax                ; EAX 복원
    ret                     ; main의 CALL Sub1 다음 명령어로 복귀
Sub1 ENDP

; ⑥ 전역 레이블 데모
GlobalDemo PROC
    jmp  MyGlobal           ; 전역 레이블로 점프
    mov  eax, 0             ; 이 줄은 실행되지 않음

MyGlobal::                  ; :: = 전역 레이블 (파일 전체에서 참조 가능)
    mov  eax, 1
    ret
GlobalDemo ENDP

END main


; ══════════════════════════════════════════════════════════════════
; [CH5-6]  Irvine32 라이브러리 — 프로시저 입출력 총정리
; ══════════════════════════════════════════════════════════════════
;
;  ※ 아래는 실행 코드가 아닌 참조용 주석 정리입니다.
;     실제 사용 시 파일 상단에: INCLUDE C:\Irvine32\Irvine32.inc
;
;  ┌─────────────────┬────────────────────────────┬──────────────┐
;  │ 프로시저        │ 입력 (CALL 전 설정)         │ 반환값       │
;  ├─────────────────┼────────────────────────────┼──────────────┤
;  │ WriteString     │ EDX = 널종료 문자열 오프셋  │ 없음         │
;  │ WriteChar       │ AL  = ASCII 문자 코드       │ 없음         │
;  │ WriteInt        │ EAX = 부호 있는 정수        │ 없음 (부호출력)│
;  │ WriteDec        │ EAX = 부호 없는 정수        │ 없음 (양수출력)│
;  │ WriteHex        │ EAX = 값                   │ 없음 (8자리HEX)│
;  │ WriteBin        │ EAX = 값                   │ 없음 (32비트BIN)│
;  │ Crlf            │ 없음                        │ 없음 (줄바꿈)│
;  │ Clrscr          │ 없음                        │ 없음 (화면지움)│
;  ├─────────────────┼────────────────────────────┼──────────────┤
;  │ ReadString      │ EDX = 버퍼 오프셋          │ EAX = 입력수 │
;  │                 │ ECX = 버퍼 최대 크기        │              │
;  │ ReadChar        │ 없음                        │ AL = 문자    │
;  │ ReadInt         │ 없음                        │ EAX = 부호정수│
;  │                 │                             │ OF=1(범위초과)│
;  │ ReadDec         │ 없음                        │ EAX = 무부호 │
;  │                 │                             │ CF=1(오류시) │
;  │ ReadHex         │ 없음                        │ EAX = 16진수 │
;  ├─────────────────┼────────────────────────────┼──────────────┤
;  │ SetTextColor    │ EAX = (배경색×16) + 전경색  │ 없음         │
;  │ GetTextColor    │ 없음                        │ AL = 색상바이트│
;  │ Gotoxy          │ DL = 열(X), DH = 행(Y)      │ 없음         │
;  │ IsDigit         │ AL = ASCII 코드             │ ZF=1(숫자)   │
;  │                 │                             │ ZF=0(숫자아님)│
;  ├─────────────────┼────────────────────────────┼──────────────┤
;  │ Randomize       │ 없음                        │ 없음 (시드초기화, 1회!)│
;  │ Random32        │ 없음                        │ EAX = 0~FFFFFFFFh│
;  │ RandomRange     │ EAX = 상한 n               │ EAX = 0~n-1  │
;  ├─────────────────┼────────────────────────────┼──────────────┤
;  │ DumpRegs        │ 없음                        │ 없음 (레지스터출력)│
;  │ DumpMem         │ ESI=시작, ECX=개수, EBX=크기│ 없음         │
;  │ GetMseconds     │ 없음                        │ EAX = 경과ms │
;  │ Delay           │ EAX = 밀리초               │ 없음         │
;  │ WaitMsg         │ 없음                        │ 없음 (키대기) │
;  └─────────────────┴────────────────────────────┴──────────────┘
;
;  색상 상수:  black=0  blue=1  green=2  cyan=3  red=4
;              magenta=5  brown=6  lightGray=7  darkGray=8
;              lightBlue=9  lightGreen=10  lightCyan=11
;              lightRed=12  lightMagenta=13  yellow=14  white=15
;
;  SetTextColor 계산 예:
;    파란 배경 + 흰 글씨 = (blue * 16) + white = (1*16)+15 = 31
;    노란 글씨 + 검은 배경 = (black * 16) + yellow = 0 + 14 = 14
;
; ── WriteString 흔한 실수 ──────────────────────────────────────
;   myStr BYTE "Hello",0
;   mov edx, myStr      ← 오류! EDX = myStr의 첫 번째 바이트 값(H=48h)
;   mov edx, OFFSET myStr  ← 올바름: EDX = 문자열의 주소
;
; ── 주요 코드 패턴 ──────────────────────────────────────────────
;
;  [WriteString]                    [WriteInt]
;  mov edx, OFFSET msg              mov eax, -500
;  call WriteString                 call WriteInt      ; "-500" 출력
;
;  [WriteDec]                       [WriteHex]
;  mov eax, 255                     mov eax, 0AFFEh
;  call WriteDec    ; "255"         call WriteHex      ; "0000AFFE"
;
;  [0~49 범위 난수 출력]
;  call Randomize                   ; 프로그램당 1회만 호출!
;  mov  eax, 50
;  call RandomRange                 ; EAX = 0~49
;  call WriteDec
;
;  [DumpMem — demoArray DWORD 5개 덤프]
;  mov esi, OFFSET demoArray
;  mov ecx, LENGTHOF demoArray      ; = 5
;  mov ebx, TYPE demoArray          ; = 4 (DWORD)
;  call DumpMem
;
;  [성능 측정 패턴]
;  call GetMseconds
;  mov  startTime, eax              ; 시작 시각
;  ; ...측정할 코드...
;  call GetMseconds
;  sub  eax, startTime              ; 경과 시간 (ms)
;  call WriteDec
;
;  [Gotoxy — 커서 (5, 10)으로 이동]
;  mov dh, 10                       ; 행 = 10
;  mov dl, 5                        ; 열 = 5
;  call Gotoxy
;
;  [IsDigit — 숫자 판별]
;  mov al, '5'
;  call IsDigit   ; ZF = 1  ('5'는 숫자)
;  mov al, 'A'
;  call IsDigit   ; ZF = 0  ('A'는 숫자 아님)
;
;  [WriteInt vs WriteDec 차이]
;  mov eax, -500
;  call WriteInt  ; "-500"         (부호 있는 출력)
;  mov eax, -500
;  call WriteDec  ; "4294966796"   (부호 없는 출력, FFFFFFFFh - 500 + 1)


; ══════════════════════════════════════════════════════════════════
; ★ 시험 직전 최종 암기 체크리스트 ★
; ══════════════════════════════════════════════════════════════════
;
;  □ 어셈블-링크-실행:  .asm→Assembler→.obj→Linker(.lib)→.exe
;  □ SBYTE 범위: -128 ~ 127   /   BYTE 범위: 0 ~ 255
;  □ 리틀 엔디안: 낮은 주소에 LSB(하위 바이트) 먼저
;     DWORD 12345678h → 메모리: [78][56][34][12]
;  □ MOV 규칙: 같은 크기, 메모리-메모리 불가
;  □ MOVZX = 부호없는 확장(0 채움), MOVSX = 부호있는 확장(MSB 채움)
;  □ INC/DEC는 CF에 영향 없음!
;  □ CF = 부호없는 오버플로 (9번째 비트 올림)
;  □ OF = 부호있는 오버플로 (양+양=음, 음+음=양)
;  □ NEG: 0이 아닌 값 → CF=1, 0 → CF=0/ZF=1, -128에 NEG → OF=1
;  □ = (재정의 가능) / EQU (재정의 불가) / TEXTEQU (재정의 가능)
;  □ $ 연산자: ListSize = ($ - list) / TYPE
;  □ TYPE=원소크기, LENGTHOF=원소개수, SIZEOF=전체바이트
;  □ PUSH: ESP-=4, [ESP]=값  /  POP: 목적지=[ESP], ESP+=4
;  □ CALL: ESP-=4, [ESP]=복귀주소, EIP=함수시작
;  □ RET : EIP=[ESP], ESP+=4
;  □ LOOP: ECX-- → ECX≠0이면 점프  (ECX=0으로 시작 = 42억회 버그!)
;  □ USES에 EAX 넣으면 반환값 사라짐!
;  □ WriteString: EDX = OFFSET 문자열  (OFFSET 빠뜨리면 오류!)
;  □ SetTextColor: EAX = (배경색 × 16) + 전경색
;  □ Randomize 1회, RandomRange: EAX=상한 → EAX=0~상한-1
