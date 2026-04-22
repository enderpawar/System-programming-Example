; ============================================================
; [5장 중간고사 출제 포인트 요약]
; ============================================================
;
; ★★★ 최우선 암기 항목 ★★★
;
; 1. PUSH / POP 동작
;    PUSH: ESP -= 4, [ESP] = 값
;    POP : 목적지 = [ESP], ESP += 4
;    POP 은 메모리를 지우지 않음 (ESP만 이동)
;    스택 방향: 높은 주소 → 낮은 주소 (아래로 성장)
;
; 2. CALL / RET 동작  (시험 단골!)
;    CALL: ① 복귀 주소를 스택에 PUSH
;          ② EIP = 피호출 프로시저 주소
;    RET : ① 스택에서 복귀 주소 POP → EIP
;          ② 호출 이후 명령어부터 실행 재개
;
; 3. PUSH/POP 균형 법칙
;    PUSH 횟수 = POP 횟수 필수
;    불균형 시 RET 이 엉뚱한 주소로 → 프로그램 충돌
;
; 4. USES 주의사항  (시험 단골!)
;    반환값 레지스터(EAX)는 USES 목록에 절대 넣지 않기!
;    USES eax → ret 전에 pop eax 삽입 → 반환값 사라짐
;
; 5. PUSHAD/POPAD
;    8개 범용 레지스터 한 번에 저장/복원
;    반환값을 EAX로 돌려줄 때 POPAD 사용 금지
;
; 6. Irvine32 입출력 레지스터 암기
;    WriteString → EDX = 오프셋   (OFFSET 필수!)
;    WriteInt    → EAX = 부호 있는 정수
;    WriteDec    → EAX = 부호 없는 정수
;    WriteChar   → AL  = ASCII 코드
;    ReadString  → EDX = 버퍼 오프셋, ECX = 버퍼 크기 → EAX = 입력 수
;    ReadInt     → EAX = 부호 있는 정수, 범위 초과 시 OF=1
;    ReadDec     → EAX = 부호 없는 정수, 오류 시 CF=1
;    RandomRange → EAX(상한+1) 입력 → EAX = 0~(상한) 난수
;
; 7. WriteString 흔한 실수
;    mov edx, myStr     → 오류! (값이 들어감)
;    mov edx, OFFSET myStr → 올바름 (주소가 들어감)
;
; 8. 스택 활용 4가지 용도
;    ① 레지스터 임시 보존
;    ② CALL의 복귀 주소 저장
;    ③ 프로시저 인수 전달
;    ④ 지역 변수 저장
;
; ─────────────────────────────────────────────────────────
; [풀어야 할 연습 파일 순서]
;   1. E5_01_Stack_Practice.asm
;   2. E5_02_Procedures_Practice.asm
;   3. E5_03_Irvine32_Practice.asm
; ─────────────────────────────────────────────────────────
