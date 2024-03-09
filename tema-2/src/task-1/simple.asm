%include "../include/io.mac"

section .text
    global simple

simple:
    ;; DO NOT MODIFY
    push    ebp
    mov     ebp, esp
    pusha

    mov     ecx, [ebp + 8]  ; len
    mov     esi, [ebp + 12] ; plain
    mov     edi, [ebp + 16] ; enc_string
    mov     edx, [ebp + 20] ; step

    ;; DO NOT MODIFY
   
    ;; Your code starts here
    xor eax, eax
    xor ebx, ebx ; contor

string_inc:
    ;; retin caracterul de la pozitia ebx
    mov al, [esi + ebx]
    ;; adaug step la caracter
    add al, dl
    ;; verific daca am trecut de 'Z'
    cmp al, 'Z'
    ;; daca nu am trecut de 'Z' nu e nevoie sa fac modificari
    jle no_overflow
    ;; am trecut de 'Z' deci scad lungimea alfabetului pentru a ajunge
    ;; la litera corecta
    sub al, 26

no_overflow:

    ;; pun caracterul pe pozitia ebx in noul sir
    mov [edi + ebx], al
    inc ebx
    ;; verific daca am parcurs len caractere
    cmp ebx, ecx
    jl string_inc


    ;; Your code ends here
    
    ;; DO NOT MODIFY

    popa
    leave
    ret
    
    ;; DO NOT MODIFY
