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