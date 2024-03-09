%include "../include/io.mac"

section .data

section .text
    global bonus

bonus:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]	; x
    mov ebx, [ebp + 12]	; y
    mov ecx, [ebp + 16] ; board

    ;; DO NOT MODIFY
    ;; FREESTYLE STARTS HERE

    mov edx, 1


    ;; in edx calculez un numar care are in descompunere binara bitii in stanga
    ;; si dreapta pozitiei date
stanga:
    ;; verific daca pot sa mut in stanga
    cmp ebx, 0
    je dreapta

    push ebx
    ;; aduc bitul pe pozitia ebx
exponent:
    shl edx, 1
    dec ebx
    cmp ebx, 0
    jg exponent

    ;; mut bitul pe pozitia ebx - 1 (stanga pozitiei date)
    pop ebx
    shr edx, 1

dreapta:
    ;; verific daca pot sa mut in dreapta
    cmp ebx, 7
    je jos
    
    ;; verific daca sunt pe prima coloana
    cmp ebx, 0
    jg dreapta_2
    
    ;; daca sunt pe prima coloana atunci pentru mutarea in dreapta pot sa
    ;; adaug direct 2
    mov edx, 2
    jmp jos

dreapta_2:
    ;; daca nu sunt pe prima coloana atunci shiftez bitul din pozitia pentru
    ;; stanga de 2 ori la stanga pentru a obtine pozitia mutarii in dreapta
    ;; in edx retin suma pozitiei mutarii la stanga si a pozitiei mutarii
    ;; la dreapta
    push ebx
    mov ebx, edx
    shl ebx, 2
    add edx, ebx
    pop ebx

jos:
    ;; verific daca am mutari in jos
    cmp eax, 0
    je sus

    ;; daca pozitia data este pe o linie > 4 atunci
    ;; mutarea in jos va fi salvata in bitii primului numar din vector,
    ;; altfel aceasta va fi salvata in bitii celui de al doilea numar
    cmp eax, 4
    jg jos_primul_numar

jos_al_doilea_numar:
    ;; marchez pe linia gasita bitii din stanga si dreapta pozitiei date
    add [ecx + eax + 3], edx
    jmp sus

jos_primul_numar:
    ;; marchez pe linia gasita bitii din stanga si dreapta pozitiei date
    add [ecx + eax - 5], edx
    jmp sus

sus:
    ;; verific daca am mutari in sus
    cmp eax, 7
    je end

    ;; daca pozitia data este pe o linie >=3 atunci mutarea in sus se va
    ;; retine in primul numar din vector, altfel aceasta se retine in al
    ;; doilea numar
    cmp eax, 3
    jge sus_primul_numar

sus_al_doilea_numar:
    ;; marchez pe linia gasita bitii din stanga si dreapta pozitiei date
    add [ecx + eax + 5], edx
    jmp end

sus_primul_numar:
    ;; marchez pe linia gasita bitii din stanga si dreapta pozitiei date
    add [ecx + eax - 3], edx
    jmp end

end:

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY