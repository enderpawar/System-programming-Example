; ============================================================
; 파일명  : 15_ConditionalJumps.asm
; 설  명  : 6장 조건 처리 (2) - 조건부 점프 (Jcond)
;           조건부 점프의 4가지 분류 + 대표 응용 예제
;           (PDF 06_Conditional Processing - Conditional Jumps)
; ============================================================
;
; [조건 구조 구현의 2단계]
;   1) CMP / AND / SUB 등이 CPU 상태 플래그를 변경
;   2) 조건부 점프(Jcond)가 그 플래그를 검사하여 분기
;
; [조건부 점프 4가지 분류 - 암기!]
;
;   (1) 특정 플래그 값에 따른 점프
;       JZ/JNZ(ZF) JC/JNC(CF) JO/JNO(OF) JS/JNS(SF) JP/JNP(PF)
;
;   (2) 같음/(E)CX 값에 따른 점프
;       JE(=, ZF=1)  JNE(≠, ZF=0)
;       JCXZ(CX=0)   JECXZ(ECX=0)
;       ※ JE=JZ, JNE=JNZ (같은 명령, 의도에 맞는 이름 선택)
;
;   (3) 부호 없는(unsigned) 정수 비교 점프
;       JA / JNBE  : 위(>)
;       JAE / JNB  : 크거나 같음(>=)
;       JB / JNAE  : 아래(<)
;       JBE / JNA  : 작거나 같음(<=)
;       (A=Above, B=Below 로 외우기)
;
;   (4) 부호 있는(signed) 정수 비교 점프
;       JG / JNLE  : 큼(>)
;       JGE / JNL  : 크거나 같음(>=)
;       JL / JNGE  : 작음(<)
;       JLE / JNG  : 작거나 같음(<=)
;       (G=Greater, L=Less 로 외우기)
;
;   ★ 시험 단골: 부호 없는→A/B,  부호 있는→G/L 구분!
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.DATA
    ; 세 정수 중 최솟값 예제용 (부호 없는 16비트)
    V1      WORD  30
    V2      WORD  10
    V3      WORD  20
    result  WORD  0

    ; 순차 검색 예제용 (16비트 정수 배열)
    intArray SWORD 0, 0, 0, 0, 1, 20, 35, -12, 66, 4, 0
    arrSize  = ($ - intArray) / TYPE intArray

.CODE
main PROC

    ; ==========================================================
    ; 1. CMP + 조건부 점프 기본형
    ; ==========================================================

    ; [예제] EAX == 5 일 때 L1 로 점프
    mov eax, 5
    cmp eax, 5              ; 같으면 ZF=1
    je  L1                  ; JE: ZF=1 이면 점프
    ; ... (EAX != 5 일 때 실행) ...
L1:

    ; ==========================================================
    ; 2. 응용: 두 정수 중 큰 값 (부호 없는)
    ;    EAX, EBX 중 큰 값을 EDX 로 이동
    ; ==========================================================
    mov eax, 25
    mov ebx, 40
    mov edx, eax           ; EAX가 크다고 가정
    cmp eax, ebx           ; EAX >= EBX 이면
    jae L2                 ;   L2로 점프 (가정 유지)
    mov edx, ebx           ; 아니면 EBX가 큼 → EDX = EBX
L2:                        ; EDX = 두 값 중 큰 값

    ; ==========================================================
    ; 3. 응용: 세 정수 중 최솟값 (부호 없는 16비트)
    ;    V1, V2, V3 중 가장 작은 값을 AX 로 이동
    ; ==========================================================
    mov ax, V1             ; V1이 최소라 가정
    cmp ax, V2             ; AX <= V2 이면
    jbe L3                 ;   L3로 점프 (V2 건너뜀)
    mov ax, V2             ; 아니면 V2가 더 작음
L3:
    cmp ax, V3             ; AX <= V3 이면
    jbe L4                 ;   L4로 점프 (V3 건너뜀)
    mov ax, V3             ; 아니면 V3가 더 작음
L4:
    mov result, ax         ; result = 최솟값 (= 10)

    ; ==========================================================
    ; 4. 응용: 상태 비트 검사 (TEST + 조건부 점프)
    ; ==========================================================
    mov al, 00100000b      ; 가상의 장치 상태 바이트
    test al, 00100000b     ; 비트5가 켜져 있는가?
    jnz DeviceOffline      ; 1이면(ZF=0) 점프 = 오프라인
    jmp CheckDone
DeviceOffline:
    ; ... 장치 오프라인 처리 ...
CheckDone:

    ; ==========================================================
    ; 5. 응용: 배열 순차 검색 (첫 0이 아닌 값 찾기)
    ;    16비트 정수 배열에서 처음으로 0이 아닌 값을 찾는다
    ; ==========================================================
    mov ebx, OFFSET intArray   ; 배열 시작 주소
    mov ecx, arrSize           ; 루프 카운터 = 원소 개수
L5:
    cmp WORD PTR [ebx], 0      ; 현재 원소가 0인가?
    jne found                  ; 0이 아니면 찾음 → 종료
    add ebx, TYPE intArray     ; 다음 원소로 이동
    loop L5                    ; ECX회 반복
    jmp notFound               ; 끝까지 0만 있었음
found:
    mov ax, [ebx]              ; AX = 찾은 0이 아닌 값 (=1)
    jmp searchDone
notFound:
    ; ... "0이 아닌 값 없음" 처리 ...
searchDone:

    INVOKE ExitProcess, 0
main ENDP

END main
