.data 
array DWORD 10000h, 20000h, 30000h, 40000h, 50000h
theSum DWORD ?

.code ; array 배열을 전부 합한느 코드 작성하기
main PROC 
    mov esi OFFSET array
    mov ecx LENGTHOF array ; array의 길이를 넣어주기
    call ArraySum
    mov theSum,eax 

    INVOKE ExitProcess,0
ENDP PORC 

ArraySum PROC ; 하지만! 여기서 USES esi ecx를 하면 push pop을 알아서 해준다!
    push esi
    push ecx
    mov eax,0
L1:
    add eax,[esi]
    add esi, TYPE DWORD
    loop L1
    pop ecx
    pop esi 
    ret
ArraySum ENDP

END main