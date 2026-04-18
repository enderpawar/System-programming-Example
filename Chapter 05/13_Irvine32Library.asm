; ============================================================
; 파일명  : 13_Irvine32Library.asm
; 설  명  : Irvine32 라이브러리 주요 프로시저 사용 예제
;           - 콘솔 I/O   : WriteString, ReadString, Crlf, Clrscr
;           - 정수 I/O   : WriteInt, ReadInt, WriteDec, ReadDec
;                          WriteHex, ReadHex, WriteBin
;           - 색상 제어  : SetTextColor, GetTextColor
;           - 랜덤 숫자  : Randomize, Random32, RandomRange
;           - 디버그 도구: DumpRegs, DumpMem
;           - 성능 측정  : GetMseconds
;           - 기타       : WaitMsg, Delay, Gotoxy, IsDigit
;           (PDF 5장 - The Irvine32 Library)
; ============================================================
;
; ┌──────────────────────────────────────────────────────────┐
; │              [Irvine32 사용을 위한 설정]                 │
; │                                                          │
; │  1) 파일 상단에 INCLUDE 디렉티브 추가                   │
; │     INCLUDE C:\Irvine32\Irvine32.inc                    │
; │                                                          │
; │  2) Visual Studio 프로젝트 속성                         │
; │     [링커] → [일반] → [추가 라이브러리 디렉터리]        │
; │       C:\Irvine32                                        │
; │     [링커] → [입력] → [추가 종속성]                     │
; │       irvine32.lib                                       │
; │                                                          │
; │  3) 각 프로시저는 CALL 명령어로 호출                     │
; │     (INVOKE 대신 직접 CALL을 써도 동일하게 동작)        │
; └──────────────────────────────────────────────────────────┘
;
; ┌──────────────────────────────────────────────────────────┐
; │         [자주 쓰는 Irvine32 프로시저 빠른 참조]          │
; │                                                          │
; │  프로시저       입력 레지스터   반환값        설명       │
; │  ─────────────────────────────────────────────────────  │
; │  WriteString    EDX(오프셋)     없음    널종료 문자열 출력│
; │  ReadString     EDX(버퍼),      EAX=    문자열 입력     │
; │                 ECX(최대길이+1) 입력수                   │
; │  WriteChar      AL(ASCII)       없음    단일 문자 출력   │
; │  ReadChar       없음            AL      단일 문자 입력   │
; │  Crlf           없음            없음    줄바꿈 출력      │
; │  Clrscr         없음            없음    화면 지우기      │
; │  WaitMsg        없음            없음    "계속하려면..." │
; │  WriteInt       EAX(부호 있음)  없음    정수 출력(부호)  │
; │  ReadInt        없음            EAX     부호정수 입력    │
; │  WriteDec       EAX(부호 없음)  없음    정수 출력(무부호)│
; │  ReadDec        없음            EAX     무부호정수 입력  │
; │  WriteHex       EAX             없음    8자리 16진수 출력│
; │  ReadHex        없음            EAX     16진수 입력      │
; │  WriteBin       EAX             없음    2진수 출력       │
; │  SetTextColor   EAX(색상)       없음    글자 색 지정     │
; │  GetTextColor   없음            AL      현재 글자 색     │
; │  Random32       없음            EAX     32비트 난수      │
; │  RandomRange    EAX(상한)       EAX     0~n-1 난수       │
; │  Randomize      없음            없음    난수 시드 초기화  │
; │  DumpRegs       없음            없음    레지스터 출력    │
; │  DumpMem     ESI,ECX,EBX        없음    메모리 덤프      │
; │  GetMseconds    없음            EAX     밀리초 반환      │
; │  Delay          EAX(ms)         없음    ms단위 대기      │
; │  Gotoxy         DL=열, DH=행    없음    커서 이동        │
; │  IsDigit        AL(ASCII)       ZF      '0'~'9' 판별    │
; └──────────────────────────────────────────────────────────┘

INCLUDE C:\Irvine32\Irvine32.inc     ; Irvine32 프로시저 선언 포함

.386
.MODEL flat, stdcall
.STACK 4096

.DATA
    ; --- 문자열 출력 예제 ---
    hello       BYTE "안녕하세요, 어셈블리!",0
    prompt      BYTE "이름을 입력하세요: ",0
    nameLabel   BYTE "당신의 이름: ",0
    nameBuffer  BYTE 32 DUP(0)       ; 입력받을 버퍼 (31자 + 널)

    ; --- 정수 출력 예제 ---
    intLabel    BYTE "정수 출력: ",0

    ; --- 색상 예제 ---
    colorMsg    BYTE "흰 글씨 / 파란 배경",0

    ; --- 랜덤 예제 ---
    randLabel   BYTE "랜덤 정수: ",0

    ; --- DumpMem 예제용 배열 ---
    demoArray   DWORD 11h, 22h, 33h, 44h, 55h

    ; --- 성능 측정 예제 ---
    timeLabel   BYTE "루프 실행 시간(ms): ",0
    startTime   DWORD ?

.CODE

; ==========================================================
; 헬퍼 프로시저: PrintNewline
;   Crlf를 호출해 줄을 바꾸는 간단한 래퍼 예제
; ==========================================================
PrintNewline PROC USES eax
    call  Crlf          ; 커서를 다음 줄 맨 앞으로 이동
    ret
PrintNewline ENDP

; ==========================================================
; main
; ==========================================================
main PROC

    ; ─────────────────────────────────────────────────────
    ; [1] 화면 지우기 & 문자열 출력
    ;     WriteString : EDX = 출력할 널종료 문자열의 오프셋
    ; ─────────────────────────────────────────────────────
    call  Clrscr                     ; 콘솔 화면 지우기

    mov   edx, OFFSET hello          ; EDX = "안녕하세요, 어셈블리!\0"
    call  WriteString                ; 문자열 출력 (줄바꿈 없음)
    call  Crlf                       ; 줄 바꿈

    ; ─────────────────────────────────────────────────────
    ; [2] 문자열 입력
    ;     ReadString : EDX = 버퍼 오프셋
    ;                  ECX = 버퍼 최대 크기 (입력 가능 수 + 1)
    ;     반환값     : EAX = 실제 입력된 문자 수
    ; ─────────────────────────────────────────────────────
    mov   edx, OFFSET prompt         ; 프롬프트 출력
    call  WriteString

    mov   edx, OFFSET nameBuffer     ; 입력 받을 버퍼
    mov   ecx, SIZEOF nameBuffer     ; 버퍼 크기 (32)
    call  ReadString                 ; 키보드에서 문자열 읽기
    ; EAX = 입력된 문자 수

    mov   edx, OFFSET nameLabel      ; "당신의 이름: " 출력
    call  WriteString
    mov   edx, OFFSET nameBuffer     ; 입력된 이름 출력
    call  WriteString
    call  Crlf

    ; ─────────────────────────────────────────────────────
    ; [3] 단일 문자 입력/출력
    ;     WriteChar : AL = 출력할 ASCII 문자 코드
    ;     ReadChar  : 반환값 AL = 입력된 문자 (에코 없음)
    ;                 확장 키 입력 시 AL = 0, AH = 스캔 코드
    ; ─────────────────────────────────────────────────────
    mov   al, 'A'
    call  WriteChar                  ; 'A' 출력
    call  Crlf

    ; call ReadChar  ; (주석 해제 시 키 하나 기다린 후 AL에 반환)

    ; ─────────────────────────────────────────────────────
    ; [4] 정수 출력
    ;     WriteInt  : EAX = 부호 있는 32비트 정수 → 부호 포함 10진수 출력
    ;     WriteDec  : EAX = 부호 없는 32비트 정수 → 부호 없는 10진수 출력
    ;     WriteHex  : EAX → 8자리 16진수 출력 (선행 0 포함)
    ;     WriteBin  : EAX → 2진수 출력 (4비트씩 묶음)
    ; ─────────────────────────────────────────────────────
    mov   edx, OFFSET intLabel
    call  WriteString

    ; 부호 있는 출력 예
    mov   eax, -12345
    call  WriteInt                   ; "-12345" 출력
    call  Crlf

    ; 부호 없는 출력 예
    mov   eax, 12345
    call  WriteDec                   ; "12345" 출력
    call  Crlf

    ; 16진수 출력 예
    mov   eax, 0AFFEh
    call  WriteHex                   ; "0000AFFE" 출력
    call  Crlf

    ; 2진수 출력 예
    mov   eax, 0101_0101b            ; MASM에서 _는 구분자로 무시됨
    call  WriteBin                   ; "0000 0000 0000 0000 0000 0000 0101 0101" 출력
    call  Crlf

    ; ─────────────────────────────────────────────────────
    ; [5] 정수 입력
    ;     ReadInt  : 반환값 EAX = 부호 있는 32비트 정수
    ;                범위 초과 입력 시 OF=1 & 오류 메시지
    ;     ReadDec  : 반환값 EAX = 부호 없는 정수
    ;                비정상 입력(공백만, 너무 큰 값) → CF=1, EAX=0
    ;     ReadHex  : 반환값 EAX = 16진수 문자열을 이진수로 변환한 값
    ; ─────────────────────────────────────────────────────
    ; call ReadInt   ; (주석 해제 시 정수 하나 입력받음)
    ; call ReadDec
    ; call ReadHex

    ; ─────────────────────────────────────────────────────
    ; [6] 텍스트 색상 설정
    ;     SetTextColor : EAX = (배경색 × 16) + 전경색
    ;
    ;     색상 상수 (Irvine32.inc에 정의):
    ;       black=0, blue=1, green=2, cyan=3, red=4
    ;       magenta=5, brown=6, lightGray=7, darkGray=8
    ;       lightBlue=9, lightGreen=10, lightCyan=11
    ;       lightRed=12, lightMagenta=13, yellow=14, white=15
    ;
    ;     예) 파란 배경(1) + 흰 글씨(15) = 1*16 + 15 = 31 (=1Fh)
    ; ─────────────────────────────────────────────────────
    mov   eax, (blue * 16) + white   ; 배경:파랑, 글씨:흰색
    call  SetTextColor

    mov   edx, OFFSET colorMsg
    call  WriteString
    call  Crlf

    ; 기본 색상으로 복원 (lightGray 배경 + black 글씨 = 7*16+0 = 70h)
    mov   eax, (black * 16) + lightGray
    call  SetTextColor

    ; GetTextColor : 반환값 AL = 현재 색상 속성
    ;   상위 4비트 = 배경색, 하위 4비트 = 전경색
    call  GetTextColor               ; AL = 현재 색상 바이트
    ; movzx eax, al  로 전체 확인 가능

    ; ─────────────────────────────────────────────────────
    ; [7] 랜덤 숫자 생성
    ;     Randomize   : 시드를 현재 시각으로 초기화 (프로그램 시작 시 1회)
    ;     Random32    : 0 ~ 0xFFFFFFFF 범위 난수 → EAX
    ;     RandomRange : 0 ~ EAX-1 범위 난수 → EAX (입력: EAX = 상한+1)
    ; ─────────────────────────────────────────────────────
    call  Randomize                  ; 난수 시드 초기화 (시각 기반)

    ; 완전한 32비트 난수 출력 (10회)
    mov   ecx, 10
randLoop1:
    call  Random32
    call  WriteDec
    call  Crlf
    loop  randLoop1

    ; 0 ~ 99 범위 난수 출력 (5회)
    mov   ecx, 5
randLoop2:
    mov   eax, 100        ; 상한: 0~99 → EAX = 100
    call  RandomRange     ; EAX = 0 ~ 99
    call  WriteDec
    call  Crlf
    loop  randLoop2

    ; ─────────────────────────────────────────────────────
    ; [8] DumpRegs — 현재 레지스터 상태를 콘솔에 출력
    ;     · EAX, EBX, ECX, EDX, ESI, EDI, EBP, ESP, EIP, EFL
    ;     · CF, SF, ZF, OF, AC, PF 플래그 값도 함께 표시
    ;     · 디버깅 시 중간중간 삽입해 레지스터 확인에 활용
    ;     (입력 없음, 반환값 없음)
    ; ─────────────────────────────────────────────────────
    mov   eax, 1234h
    mov   ebx, 5678h
    call  DumpRegs        ; 레지스터 스냅샷 출력

    ; ─────────────────────────────────────────────────────
    ; [9] DumpMem — 지정한 메모리 구간을 16진수로 출력
    ;     입력: ESI = 시작 주소
    ;           ECX = 단위 수 (몇 개 출력할지)
    ;           EBX = 단위 크기 (1=바이트, 2=워드, 4=더블워드)
    ; ─────────────────────────────────────────────────────
    mov   esi, OFFSET demoArray      ; 배열 시작 주소
    mov   ecx, LENGTHOF demoArray    ; 원소 수 (5)
    mov   ebx, TYPE demoArray        ; 단위 크기 (4 = DWORD)
    call  DumpMem                    ; 16진수 메모리 덤프 출력
    ; 출력 예: 00000011  00000022  00000033  00000044  00000055

    ; ─────────────────────────────────────────────────────
    ; [10] 커서 이동
    ;      Gotoxy : DL = 열(X, 0~79), DH = 행(Y, 0~24)
    ; ─────────────────────────────────────────────────────
    mov   dh, 10         ; 행 10
    mov   dl, 5          ; 열 5
    call  Gotoxy         ; 커서를 (5, 10)으로 이동
    mov   edx, OFFSET hello
    call  WriteString    ; 해당 위치에 출력

    ; ─────────────────────────────────────────────────────
    ; [11] IsDigit — ASCII 코드가 숫자 문자인지 판별
    ;     입력 : AL = ASCII 코드
    ;     반환 : ZF=1 → '0'~'9' 범위 (숫자)
    ;            ZF=0 → 숫자 아님
    ; ─────────────────────────────────────────────────────
    mov   al, '5'
    call  IsDigit        ; ZF = 1 ('5'는 숫자)
    ; JE isNum 형태로 분기 가능

    mov   al, 'A'
    call  IsDigit        ; ZF = 0 ('A'는 숫자 아님)

    ; ─────────────────────────────────────────────────────
    ; [12] 성능 측정 — GetMseconds
    ;     자정 이후 경과한 밀리초를 EAX로 반환
    ;     코드 블록 앞뒤에서 호출 → 차이 = 실행 시간
    ; ─────────────────────────────────────────────────────
    call  GetMseconds
    mov   startTime, eax             ; 시작 시각 저장

    ; --- 시간을 측정할 코드 블록 ---
    mov   ecx, 1000000               ; 100만 번 루프
dummyLoop:
    nop
    loop  dummyLoop

    call  GetMseconds                ; 종료 시각
    sub   eax, startTime             ; 경과 시간 (ms)

    mov   edx, OFFSET timeLabel
    call  WriteString
    call  WriteDec                   ; 경과 시간 출력
    call  Crlf

    ; ─────────────────────────────────────────────────────
    ; [13] Delay — 지정한 밀리초 동안 프로그램 일시 정지
    ;     입력 : EAX = 지연 시간 (밀리초)
    ; ─────────────────────────────────────────────────────
    mov   eax, 500                   ; 0.5초 대기
    call  Delay

    ; ─────────────────────────────────────────────────────
    ; [14] WaitMsg — "계속하려면 아무 키나 누르세요..." 표시 후 대기
    ;     · 화면 내용이 사라지기 전에 사용자에게 볼 시간을 줄 때 사용
    ;     · Clrscr 직전에 호출하면 좋음
    ; ─────────────────────────────────────────────────────
    call  WaitMsg

    INVOKE ExitProcess, 0
main ENDP

END main
