.data 
    arr WORD 10,20,30,40 
    sum word 0
    count = ($-arr) / type arr
.code 
    mov ebx, 0
    mov ecx,count 
SUM:
   
    mov ax, [arr+ebx] 
    add ebx, type arr 
    add sum, ax
LOOP SUM 

.data

source BYTE "This is Source index"
target BYTE SIZEOF source DUP(0) ; target에는 source의 길이만큼 0을 초기화해줘야한다.

.code 
main PROC

    mov esi,0
    mov eci, LENGTHOF source

L1:
    mov al, source[esi]
    mov target[esi] ,al 
    inc esi 
loop L1
inovke ExitProcess,0
main ENDP
END main

.DATA 

PBYTE TYPEDEF PTR BYTE
PWORD TYPEDEF PTR WORD 

ptr1 PBYTE array 