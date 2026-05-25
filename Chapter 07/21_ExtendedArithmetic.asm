; ============================================================
; 파일명  : 21_ExtendedArithmetic.asm
; 설  명  : 7장 정수 산술 (4) - 확장 덧셈 & 뺄셈
;           ADC (add with carry) / SBB (subtract with borrow)
;           (PDF 07_Integer Arithmetic - Extended Addition and Subtraction)
; ============================================================
;
; [핵심] 레지스터 크기를 넘는 큰 정수를 여러 조각으로 나눠
;        Carry(빌림)를 다음 조각으로 전달하며 계산한다.
;   ADC 목적지, 소스 → 목적지 = 목적지 + 소스 + CF
;   SBB 목적지, 소스 → 목적지 = 목적지 - 소스 - CF
;   ※ 피연산자 규칙은 ADD/SUB와 동일, 두 피연산자 크기 같아야 함
; ============================================================

.386
.MODEL flat, stdcall
.STACK 4096

ExitProcess PROTO, dwExitCode:DWORD

.CODE
main PROC

    ; ==========================================================
    ; 1. ADC - 8비트 두 수의 합을 16비트로 (FFh + FFh)
    ;    하위 바이트 ADD에서 발생한 CF를 상위 바이트에 ADC로 전달
    ; ==========================================================
    mov dl, 0              ; 상위 바이트 누적용 (초기 0)
    mov al, 0FFh
    add al, 0FFh           ; AL = FEh, CF=1 (올림 발생)
    adc dl, 0              ; DL = 0 + 0 + CF(1) = 1
    ; → DL:AL = 01FEh (= 255 + 255 = 510)

    ; ==========================================================
    ; 2. ADC - 32비트 두 수의 합을 64비트로
    ;    (FFFFFFFFh + FFFFFFFFh)
    ; ==========================================================
    mov edx, 0
    mov eax, 0FFFFFFFFh
    add eax, 0FFFFFFFFh    ; EAX = FFFFFFFEh, CF=1
    adc edx, 0             ; EDX = 0 + 0 + CF(1) = 1
    ; → EDX:EAX = 00000001FFFFFFFEh

    ; ==========================================================
    ; 3. SBB - 64비트 뺄셈 (32비트 피연산자 사용)
    ;    EDX:EAX 에서 1을 빼기
    ;    하위 SUB에서 빌림(CF) 발생 → 상위에 SBB로 빌림 전달
    ; ==========================================================
    mov edx, 1
    mov eax, 0             ; EDX:EAX = 0000000100000000h
    sub eax, 1             ; EAX = FFFFFFFFh, CF=1 (빌림 발생)
    sbb edx, 0             ; EDX = 1 - 0 - CF(1) = 0
    ; → EDX:EAX = 00000000FFFFFFFFh

    INVOKE ExitProcess, 0
main ENDP

END main
