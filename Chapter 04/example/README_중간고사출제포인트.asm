; ============================================================
; [4장 중간고사 출제 포인트 요약]
; ============================================================
;
; ★★★ 최우선 암기 항목 ★★★
;
; 1. MOV 규칙 (시험 단골!)
;    메모리→메모리 직접 이동 불가  (레지스터 경유 필수)
;    피연산자 크기 반드시 일치
;    EIP 는 목적지 불가
;
; 2. MOVZX vs MOVSX
;    MOVZX : 상위 비트를 0으로 채움  → 부호 없는 값
;    MOVSX : 상위 비트를 MSB로 채움  → 부호 있는 값
;    BL=F0h: movzx eax,bl → 000000F0h (+240)
;            movsx eax,bl → FFFFFFF0h (-16)
;
; 3. CF vs OF  (시험 단골!)
;    CF : 부호 없는(Unsigned) 연산 오버플로 감지
;    OF : 부호 있는(Signed)   연산 오버플로 감지
;    INC/DEC 는 CF에 영향 없음!
;
; 4. 플래그 예시
;    AL=7Fh(127), add al,1 → AL=80h(-128), CF=0, OF=1
;    AL=FFh(255), add al,1 → AL=0,         CF=1, OF=0, ZF=1
;
; 5. TYPE / LENGTHOF / SIZEOF
;    arr DWORD 1,2,3,4,5 →
;      TYPE=4  LENGTHOF=5  SIZEOF=20
;    SIZEOF = TYPE × LENGTHOF
;
; 6. PTR 연산자 (리틀 엔디안 + PTR)
;    myDouble DWORD 12345678h
;    WORD PTR myDouble → AX = 5678h (하위 워드)
;    BYTE PTR myDouble → AL = 78h   (최하위 바이트)
;
; 7. LOOP 의 치명적 실수
;    ECX = 0 으로 시작하면 → FFFFFFFFh 번 반복 (42억 회!)
;
; 8. 배열 합산 7단계 패턴
;    ① mov esi, OFFSET 배열
;    ② mov ecx, LENGTHOF 배열
;    ③ mov eax, 0
;    ④ 루프레이블:
;    ⑤   add eax, [esi]
;    ⑥   add esi, TYPE 배열   (BYTE=1, WORD=2, DWORD=4)
;    ⑦   loop 루프레이블
;
; ─────────────────────────────────────────────────────────
; [풀어야 할 연습 파일 순서]
;   1. E4_01_MOV_Practice.asm
;   2. E4_02_Arithmetic_Flags_Practice.asm
;   3. E4_03_IndirectAddr_Loop_Practice.asm
; ─────────────────────────────────────────────────────────
