; ============================================================
; 파일명  : 00_StudyNotes.asm
; 설  명  : 5장 Procedures — 시험 직전 핵심 요약 + 퀴즈
;           (빌드 불가 — 학습/복습 전용 노트)
; ============================================================

; ╔══════════════════════════════════════════════════════════╗
; ║                 SECTION 1: 런타임 스택                   ║
; ╚══════════════════════════════════════════════════════════╝
;
; 1-1. 스택의 특성
;   · LIFO (Last-In, First-Out)
;   · 높은 주소 → 낮은 주소 방향으로 성장 (top이 낮은 주소)
;   · ESP (Extended Stack Pointer) 가 top을 가리킴
;
; 1-2. PUSH 동작 (32비트 피연산자 기준)
;   ① ESP -= 4
;   ② [ESP] = 값
;
; 1-3. POP 동작 (32비트 피연산자 기준)
;   ① 목적지 = [ESP]
;   ② ESP += 4
;   ※ POP은 메모리를 지우지 않음. ESP만 이동.
;
; 1-4. 스택 활용 용도 (시험 자주 출제!)
;   ① 레지스터 임시 보존
;   ② CALL 명령어의 복귀 주소 저장
;   ③ 프로시저에 인수(argument) 전달
;   ④ 프로시저 내 지역 변수 저장
;
; 1-5. PUSH/POP 변형 명령어
;   ┌─────────────────┬────────────────────────────────────┐
;   │ PUSHFD          │ EFLAGS 전체 → 스택 (32비트)        │
;   │ POPFD           │ 스택 → EFLAGS                      │
;   │ PUSHAD          │ 8개 32비트 범용 레지스터 → 스택    │
;   │                 │ 순서: EAX,ECX,EDX,EBX,ESP,EBP,ESI,EDI │
;   │ POPAD           │ 스택 → 8개 레지스터 (역순)         │
;   │ PUSHA / POPA    │ 16비트 모드 전용                   │
;   └─────────────────┴────────────────────────────────────┘
;
; ☑ 퀴즈 1: 다음 실행 후 EAX, EBX의 값은?
;   push 10
;   push 20
;   pop  eax     ; EAX = ?
;   pop  ebx     ; EBX = ?
;   → EAX = 20, EBX = 10

; ╔══════════════════════════════════════════════════════════╗
; ║               SECTION 2: 프로시저 정의와 호출            ║
; ╚══════════════════════════════════════════════════════════╝
;
; 2-1. 프로시저 구조
;   이름 PROC
;       ...
;       ret
;   이름 ENDP
;
; 2-2. CALL 명령어 동작
;   ① 복귀 주소 (CALL 다음 명령어 주소) → 스택에 PUSH
;   ② 피호출 프로시저 시작 주소 → EIP에 복사
;
; 2-3. RET 명령어 동작
;   ① 스택에서 복귀 주소 POP → EIP에 저장
;   ② 호출 이후 명령어부터 실행 재개
;
; 2-4. 레이블 범위
;   · 기본: 레이블은 선언된 프로시저 내에서만 유효
;   · 전역 레이블: 이름:: (콜론 두 개) → 다른 프로시저에서도 JMP 가능
;
; 2-5. USES 연산자
;   이름 PROC USES reg1 reg2 reg3
;   · 어셈블러가 시작 시 자동 PUSH, 종료 시 자동 POP 코드 삽입
;   · 반환값 레지스터(보통 EAX)는 USES 목록에 넣으면 안 됨!
;
; 2-6. 중첩 호출 (Nested Calls)
;   main → Sub1 → Sub2 → Sub3
;   · 각 CALL마다 복귀 주소가 스택에 쌓임
;   · 각 RET마다 역순으로 복귀 주소를 꺼내 돌아감
;   · 스택은 자동으로 올바른 복귀 순서를 보장
;
; 2-7. 레지스터를 통한 인수 전달
;   · 고수준 언어와 달리, 어셈블리는 CALL 전에 레지스터에 값 설정
;   · 예: SumOfThree → EAX, EBX, ECX에 더할 값 넣고 CALL
;
; 2-8. 반환값 규약
;   · 보통 EAX에 반환값을 저장하고 RET
;   · 반환값 레지스터는 PUSH/POP 또는 USES로 보존하면 안 됨
;
; ☑ 퀴즈 2: 다음 코드에서 CALL 실행 직후 ESP는?
;   (CALL 전 ESP = 0100h, CALL 명령어는 00000020h에 위치)
;   CALL MySub
;   → ESP = 00FCh (ESP -= 4), [00FCh] = 00000025h (복귀 주소)
;
; ☑ 퀴즈 3: 다음 코드의 문제점은?
;   BadProc PROC USES eax
;       mov eax, 42    ; 반환값을 EAX에 저장
;       ret            ; USES가 pop eax 삽입 → EAX가 원래 값으로 덮어써짐
;   BadProc ENDP
;   → EAX를 USES에 포함시켜 반환값이 사라짐 (USES에서 EAX 제거해야 함)

; ╔══════════════════════════════════════════════════════════╗
; ║            SECTION 3: Irvine32 라이브러리                ║
; ╚══════════════════════════════════════════════════════════╝
;
; 3-1. 라이브러리 개념
;   · 미리 어셈블된 프로시저들의 집합 (.lib 파일)
;   · PROTO 디렉티브로 프로시저 원형을 선언
;   · 링커(Linker)가 CALL 목적지 주소를 채워 넣음
;   · INCLUDE 파일(.inc)에 PROTO와 상수들이 미리 선언되어 있음
;
; 3-2. 주요 프로시저 입출력 정리 (암기 필수!)
;
;   [출력 계열]
;   WriteString  → EDX = 문자열 오프셋
;   WriteChar    → AL  = ASCII 문자 코드
;   WriteInt     → EAX = 부호 있는 정수 (부호 포함 10진수 출력)
;   WriteDec     → EAX = 부호 없는 정수 (10진수 출력)
;   WriteHex     → EAX → 8자리 16진수 출력 (선행 0 포함)
;   WriteHexB    → EAX = 값, EBX = 바이트 수 (1,2,4)
;   WriteBin     → EAX → 32비트 2진수 출력 (4비트씩 공백 구분)
;   Crlf         → (없음) → 줄바꿈
;   Clrscr       → (없음) → 화면 지우기
;
;   [입력 계열]
;   ReadString   → EDX = 버퍼 오프셋, ECX = 버퍼 크기 / 반환: EAX = 문자 수
;   ReadChar     → (없음) / 반환: AL = 문자 (확장키는 AL=0, AH=스캔코드)
;   ReadInt      → (없음) / 반환: EAX = 부호 있는 정수, 범위초과 시 OF=1
;   ReadDec      → (없음) / 반환: EAX = 부호 없는 정수, 오류 시 CF=1
;   ReadHex      → (없음) / 반환: EAX = 16진수 입력 값
;
;   [제어 계열]
;   SetTextColor → EAX = (배경색 × 16) + 전경색
;   GetTextColor → (없음) / 반환: AL = 색상 바이트
;   Gotoxy       → DL = 열(X), DH = 행(Y)
;   Delay        → EAX = 지연 시간 (밀리초)
;   WaitMsg      → (없음) → "계속하려면..." 메시지 & 대기
;   IsDigit      → AL = ASCII / 반환: ZF=1 ('0'~'9'), ZF=0 (아님)
;
;   [난수 계열]
;   Randomize    → (없음) → 시드 초기화 (프로그램 당 1회 호출)
;   Random32     → (없음) / 반환: EAX = 0 ~ FFFFFFFFh 난수
;   RandomRange  → EAX = 상한(n) / 반환: EAX = 0 ~ n-1 난수
;
;   [디버그/유틸]
;   DumpRegs     → (없음) → 레지스터 전체 상태 출력
;   DumpMem      → ESI=시작주소, ECX=단위수, EBX=단위크기(1/2/4)
;   GetMseconds  → (없음) / 반환: EAX = 자정 이후 경과 밀리초
;
; 3-3. 색상 상수 (SetTextColor 사용 시)
;   black=0    blue=1    green=2    cyan=3
;   red=4      magenta=5 brown=6    lightGray=7
;   darkGray=8 lightBlue=9 lightGreen=10 lightCyan=11
;   lightRed=12 lightMagenta=13 yellow=14 white=15
;
;   예) 노란 글씨 + 검은 배경 = (black * 16) + yellow = 14
;
; ☑ 퀴즈 4: 다음 코드의 출력 결과는?
;   mov eax, -500
;   call WriteInt    ; → "-500"
;   mov eax, -500
;   call WriteDec    ; → ???
;   → WriteDec는 부호 없는 출력 → 4294966796 (0xFFFFFE0C)
;
; ☑ 퀴즈 5: 0~49 범위의 난수를 출력하는 코드를 작성하라.
;   call  Randomize
;   mov   eax, 50        ; 상한 = 50 → 0~49
;   call  RandomRange    ; EAX = 0 ~ 49
;   call  WriteDec

; ╔══════════════════════════════════════════════════════════╗
; ║              SECTION 4: 자주 나오는 패턴 코드            ║
; ╚══════════════════════════════════════════════════════════╝
;
; ─── 패턴 A: 배열 합산 프로시저 (ArraySum) ───────────────
;
;   ArraySum PROC
;       push esi
;       push ecx
;       mov  eax, 0
;   L1:
;       add  eax, [esi]
;       add  esi, 4
;       loop L1
;       pop  ecx
;       pop  esi
;       ret
;   ArraySum ENDP
;
;   호출 방법:
;       mov esi, OFFSET 배열이름
;       mov ecx, LENGTHOF 배열이름
;       call ArraySum            ; EAX = 합계
;
; ─── 패턴 B: EFLAGS 보존 ─────────────────────────────────
;
;   pushfd
;       ... (플래그를 변경하는 코드) ...
;   popfd
;
; ─── 패턴 C: USES를 이용한 레지스터 자동 보존 ────────────
;
;   MyProc PROC USES ebx ecx esi   ; EAX는 반환값이면 빼야 함
;       ...
;       ret
;   MyProc ENDP
;
; ─── 패턴 D: 성능 측정 ───────────────────────────────────
;
;   call GetMseconds
;   mov  startTime, eax
;       ... (측정할 코드) ...
;   call GetMseconds
;   sub  eax, startTime           ; 경과 시간(ms)

; ╔══════════════════════════════════════════════════════════╗
; ║                 SECTION 5: 흔한 실수 모음                ║
; ╚══════════════════════════════════════════════════════════╝
;
; ✗ 실수 1: PUSH/POP 불균형
;   push eax
;   push ebx
;   pop  eax     ; ebx가 eax로 복원됨 → 레지스터 교환 버그
;   pop  ebx     ; eax가 ebx로 복원됨
;
; ✗ 실수 2: 반환값 레지스터를 USES에 포함
;   Foo PROC USES eax   ; EAX에 반환값 저장하는데 USES에 넣음 → 값 사라짐
;
; ✗ 실수 3: ECX=0인 상태로 LOOP 시작
;   mov ecx, 0
;   L1: ...
;   loop L1     ; ECX가 -1 (0xFFFFFFFF)이 되어 약 42억 번 반복!
;
; ✗ 실수 4: 프로시저 내 레지스터 미복원 후 복귀
;   MyProc PROC
;       mov esi, 999   ; ESI 변경
;       ret            ; ESI가 복원되지 않은 채 복귀 → 호출자 ESI 오염
;   MyProc ENDP
;
; ✗ 실수 5: WriteString에 오프셋 대신 값을 전달
;   mov edx, myStr     ; 잘못됨: myStr의 첫 번째 바이트 값을 EDX에 저장
;   mov edx, OFFSET myStr   ; 올바름: 문자열의 주소(오프셋)를 EDX에 저장
