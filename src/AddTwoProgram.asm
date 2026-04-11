; ============================================================
; 파일명  : AddTwoProgram.asm
; 설  명  : 두 정수를 더하는 가장 기본적인 어셈블리 프로그램
;           (PDF 3장 "First Assembly Language Program" 예제)
; ============================================================

; [1] .386 디렉티브 - 이 프로그램이 32비트(IA-32) 명령어 집합을 사용함을 선언
.386

; [2] .MODEL 디렉티브 - 메모리 모델과 호출 규약을 지정
;     flat     : 32비트 프로그램에서 항상 사용하는 단일 평면 메모리 모델
;     stdcall  : 32비트 Windows 서비스가 요구하는 호출 규약
.MODEL flat, stdcall

; [3] .STACK 디렉티브 - 런타임 스택에 사용할 메모리 크기(바이트)를 지정
;     4096 바이트 = 메모리 한 페이지 크기
;     스택은 함수 호출 시 전달 인자와 복귀 주소를 저장하는 데 사용됨
.STACK 4096

; [4] ExitProcess 함수 프로토타입 선언
;     이 함수는 Windows OS가 제공하는 서비스로, 프로그램을 종료하고 제어를 OS로 반환
;     dwExitCode : 0이면 정상 종료, 0이 아니면 오류 코드
ExitProcess PROTO, dwExitCode:DWORD

; [5] .CODE 디렉티브 - 실행 가능한 명령어가 들어가는 코드 세그먼트의 시작
.CODE

; [6] main PROC - 프로시저(함수)의 시작 선언, 프로그램의 진입점(entry point)
main PROC

    ; mov eax, 5  : 정수 5를 EAX 레지스터에 복사 (목적지 = 소스)
    mov eax, 5

    ; add eax, 6  : EAX 레지스터의 값(5)에 6을 더함 -> EAX = 11
    add eax, 6

    ; ExitProcess(0) 호출 - 프로그램을 정상 종료
    INVOKE ExitProcess, 0

; [7] main ENDP - 프로시저의 끝 표시 (PROC와 이름이 일치해야 함)
main ENDP

; [8] END 디렉티브 - 어셈블러가 처리할 마지막 줄을 표시하고 진입점을 지정
;     이 줄 이후의 코드는 어셈블러가 무시함
END main
