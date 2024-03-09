%include "../include/io.mac"

struc proc
    .pid: resw 1
    .prio: resb 1
    .time: resw 1
endstruc

section .text
    global sort_procs

sort_procs:
    ;; DO NOT MODIFY
    enter 0,0
    pusha

    mov edx, [ebp + 8]      ; processes
    mov eax, [ebp + 12]     ; length
    ;; DO NOT MODIFY

    ;; Your code starts here
    mov ebp, esp

    xor ebx, ebx
    xor ecx, ecx

    ;; salvez lungimea vectorului
    mov ebx, edx
    xor edx, edx

    ;; retin memoria totala ocupata de vector (length * struct_size)
    mov ecx, proc_size
    mul ecx
    
    ;; mut inapoi lungimea vectorului
    mov edx, ebx
    xor ecx, ecx

    ;; retin in ebx pozitia in vector a ultimului element
    mov ebx, eax
    sub ebx, proc_size

    ;; resetez eax si il voi folosi ca auxiliar
    xor eax, eax
    jmp sort
    
swap:
    ;; interschimbare prioritate
    xor eax, eax
    mov al, [edx + ebx + proc.prio]
    push eax
    mov al, [edx + ecx + proc.prio]
    mov [edx + ebx + proc.prio], al
    pop eax
    mov [edx + ecx + proc.prio], al

    ;; interschimbare timp
    xor eax, eax
    mov ax, [edx + ebx + proc.time]
    push eax
    mov ax, [edx + ecx + proc.time]
    mov [edx + ebx + proc.time], ax
    pop eax
    mov [edx + ecx + proc.time], ax

    ;; interschimbare pid
    xor eax, eax
    mov ax, [edx + ebx + proc.pid]
    push eax
    mov ax, [edx + ecx + proc.pid]
    mov [edx + ebx + proc.pid], ax
    pop eax
    mov [edx + ecx + proc.pid], ax

    jmp verify_sorting_status

sort:
    ;; fac un selectionsort, parcurg vectorul de la dreapta la stanga
    ;; cu ebx, la fiecare pas caut in subvectorul din stanga lui
    ;; elementul maxim conform regulilor si il interschimb cu elementul
    ;; de pe pozitia ebx. a doua parcurgere este efectuata cu ecx
    mov ecx, ebx

compare_elements:
    sub ecx, proc_size

    ;; comparare prioritate
    xor eax, eax
    mov al, [edx + ebx + proc.prio]
    cmp al, [edx + ecx + proc.prio]
    jl swap
    ;; daca prioritatea este mai mare atunci trec la urmatorul element
    ;; din vector
    cmp al, [edx + ecx + proc.prio]
    jg verify_sorting_status

    ;; comparare timp
    xor eax, eax
    mov ax, [edx + ebx + proc.time]
    cmp ax, [edx + ecx + proc.time]
    jl swap
    cmp ax, [edx + ecx + proc.time]
    jg verify_sorting_status

    ;; comparare pid
    xor eax, eax
    mov ax, [edx + ebx + proc.pid]
    cmp ax, [edx + ecx + proc.pid]
    jl swap

verify_sorting_status:
    ;; daca nu sunt pe primul element din vector atunci continui parcurgerea
    cmp ecx, 0
    jg compare_elements

    ;; daca am terminat parcurgerea cu ecx atunci pe pozitia ebx este elementul
    ;; minim, continuand astfel la urmatorul element din vector
    sub ebx, proc_size
    ;; daca nu am ajuns cu ebx pe primul element din vector inseamna ca nu am
    ;; terminat de sortat vectorul
    cmp ebx, 0
    jg sort

    mov esp, ebp
    ;; Your code ends here
    
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY