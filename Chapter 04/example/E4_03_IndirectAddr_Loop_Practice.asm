; ============================================================
; [시험 대비 빈칸 채우기] 4장 - 간접 주소지정 / PTR / JMP / LOOP
; 빈칸( ______ )을 채우세요. 정답은 E4_03_IndirectAddr_Loop_Answer.asm 참고.
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    byteArr  BYTE   10h, 20h, 30h, 40h, 50h
    wordArr  WORD   100h, 200h, 300h, 400h
    dwordArr DWORD  1000h, 2000h, 3000h, 4000h

    myDouble DWORD  12345678h
    intArray DWORD  1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    arraySum DWORD  0

    source   BYTE   "Hello!", 0
    target   BYTE   SIZEOF source DUP(0)

.CODE
main PROC

; ──────────────────────────────────────────────────────────
; [문제 1] PTR 연산자 — myDouble DWORD 12345678h 기준
;
;   x86 리틀 엔디안: 낮은 주소에 (1)______ 바이트 먼저 저장 ; 최하위 
;   메모리: [addr+0]=(2)______, [+1]=(3)______, [+2]=(4)______, [+3]=(5)______ ; 78/ 56/34/12
;
;   mov ax, WORD PTR myDouble          ; AX = (6)______ ; 5678h
;   mov al, BYTE PTR myDouble          ; AL = (7)______ ; 78h
;   mov al, BYTE PTR [myDouble + 3]    ; AL = (8)______ ; 12h 
; ──────────────────────────────────────────────────────────

; [문제 2] 간접 피연산자 — 빈칸을 채우세요.
;
;   mov esi, (9)______ byteArr ; OFFSET 
;   mov al,  (10)______ ; [esi]
;
;   크기가 불명확할 때 PTR 필요:
;   inc (11)______ 
;   inc (12)______ PTR [esi]

; ──────────────────────────────────────────────────────────
; [문제 3] 배열 순회 — 타입별 ESI 증가량
;
;   BYTE  배열 → add esi, (13)______
;   WORD  배열 → add esi, (14)______
;   DWORD 배열 → add esi, (15)______
;
;   byteArr 를 앞에서부터 3개 읽는 코드:
;   mov esi, OFFSET byteArr
;   mov al,  (16)______
;   (17)______ esi
;   mov al,  [esi]
;   add esi, (18)______
;   mov al,  [esi]

; ──────────────────────────────────────────────────────────
; [문제 4] 인덱스 피연산자 & 스케일 팩터
;
;   mov esi, 0
;   mov al, (19)______           ; byteArr[0]
;   inc esi
;   mov al, [byteArr + esi]      ; byteArr[1] = (20)______ 
;
;   DWORD 배열 인덱스 2 접근 (스케일 팩터):
;   mov esi, 2
;   mov eax, [dwordArr + esi * (21)______]
;
;   WORD 배열 인덱스 3 접근 (스케일 팩터):
;   mov esi, 3
;   mov ax, [wordArr + esi * (22)______]

; ──────────────────────────────────────────────────────────
; [문제 5] JMP / LOOP — 빈칸을 채우세요.
;
;   JMP:
;   · 목적지 레이블의 오프셋을 (23)______ 레지스터에 로드 EIP 
;   · (24)______ 점프 ; 무조건 
;
;   LOOP 실행 순서:
;   ① (25)______ -= 1 ;ecx 
;   ② (25)______ ≠ 0 이면 레이블로 점프  
;      (25)______ = 0 이면 다음 명령어로 진행
;
;   치명적 실수: LOOP 전 ECX = (26)______ 이면 0
;     첫 실행 후 ECX = (27)______ ; 오버플로우가 일어나므로 조심해야한다!

; ──────────────────────────────────────────────────────────
; [문제 6] 배열 합산 7단계 — 빈칸을 채우세요.
;
;   mov (28)______, OFFSET intArray ;eax 
;   mov (29)______, LENGTHOF intArray ;ecx 
;   mov (30)______, 0 ; esi -> 이걸 인덱스라 생각하면 돼
;
;   sumLoop:
;       (31)______ eax, [(32)______] ; add, esi
;       add esi, (33)______ intArray ; TYPE 
;       (34)______ sumLoop ;loop 
;
;   mov arraySum, eax
;   ; 1+2+...+10 = (35)______ ; 55

; ──────────────────────────────────────────────────────────
; [문제 7] 문자열 복사 패턴 — 빈칸을 채우세요.
;
;   mov esi, (36)______ ; 0 
;   mov ecx, (37)______ source ; SIZEOF 
;
;   copyLoop:
;       mov al, (38)______[esi] ; source 
;       mov (39)______[esi], al ; target  
;       (40)______ esi ; INC 
;       (41)______ copyLoop ;loop 

    mov esi, OFFSET intArray
    mov ecx, LENGTHOF intArray
    mov eax, 0
sumLoop:
    add eax, [esi]
    add esi, TYPE intArray
    loop sumLoop
    mov arraySum, eax

    INVOKE ExitProcess, 0
main ENDP
END main
