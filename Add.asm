.data ; this is the data area
sum DWORD 0 ;create a variable to store the sum 

.code ; this is the code area
main PROC
    mov eax, 5 ;먼저 eax로 옮기고, 
    add eax, 6 ; eax에 있는 5에 6을 더해주기
    mov sum, eax ; 바로 메모리에서 옮기지 못하니까 eax를 sum으로 옮기기. 그래야지 메모리에 저장되니까

    INVOKE ExitProcess, 0
main ENDP