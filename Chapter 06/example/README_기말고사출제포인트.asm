; ============================================================
; [6장 기말고사 출제 포인트 요약]
; ============================================================
;
; ★★★ 최우선 암기 항목 ★★★
;
; 1. 불리언 명령어 플래그 (시험 단골!)
;    AND/OR/XOR/TEST → 항상 OF=0, CF=0 / SF,ZF,PF는 결과 따라
;    NOT → 어떤 플래그도 변경 안 함! ★
;    CMP → 뺄셈 결과 기준으로 OF,SF,ZF,CF,AF,PF 변경
;
; 2. 비트 마스킹
;    비트 끄기 → AND,  켜기 → OR,  토글 → XOR
;    대문자화 → AND ch, 11011111b (0DFh)
;
; 3. 집합 연산
;    여집합 → NOT,  교집합 → AND,  합집합 → OR
;
; 4. 조건부 점프 4분류 (★★★ 최빈출 ★★★)
;    부호 없는 → A(Above)/B(Below) : JA JAE JB JBE
;    부호 있는 → G(Greater)/L(Less): JG JGE JL JLE
;    JE=JZ, JNE=JNZ, JCXZ/JECXZ
;    ※ 음수 비교에서 A/B 와 G/L 혼동 = 논리 버그!
;
; 5. CMP 결과 (부호 없는)
;    목적지 < 소스 → CF=1
;    목적지 = 소스 → ZF=1
;    목적지 > 소스 → CF=0, ZF=0
;
; 6. 조건부 루프
;    LOOPE/LOOPZ   → ECX!=0 그리고 ZF=1 이면 점프
;    LOOPNE/LOOPNZ → ECX!=0 그리고 ZF=0 이면 점프
;    LOOPNZ 앞에서 PUSHFD/POPFD 로 플래그 보존 (ADD가 ZF 덮어씀)
;
; 7. 조건 구조 변환 정석
;    IF-ELSE : 조건을 '반대로' 뒤집어 ELSE 레이블로 점프
;    WHILE   : 조건 반대로 뒤집어 endwhile 로 점프
;    변수끼리 직접 CMP 불가 → 한쪽을 레지스터로 옮김
;
; 8. 고수준 디렉티브
;    .IF/.ELSEIF/.ELSE/.ENDIF, .WHILE/.ENDW, .REPEAT/.UNTIL
;    ★ 레지스터끼리 .IF 비교 → MASM은 기본 '부호 없는' 비교 생성
;
; ─────────────────────────────────────────────────────────
; [풀어야 할 연습 파일 순서]
;   1. E6_01_Boolean_Practice.asm
;   2. E6_02_ConditionalJumps_Practice.asm
;   3. E6_03_Structures_Practice.asm
; ─────────────────────────────────────────────────────────
