
section .data

section .text
	global checkers

checkers:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]	; x
    mov ebx, [ebp + 12]	; y
    mov ecx, [ebp + 16] ; table

    ;; DO NOT MODIFY
    ;; FREESTYLE STARTS HERE

    ;; inmultesc eax cu 8
    mov edx, 8
    mul edx
    xor edx, edx
    ;; ecx arata catre pozitia din matrice la coordonatele date
    add ecx, eax
    add ecx, ebx

complete_down_left:
    ;; verific daca sunt pe prima linie, caz in care nu am ce completa
    cmp eax, 0
    ;; pot sa sar direct la completarea liniei de deasupra
    je complete_up_left

    ;; verific daca sunt pe prima coloana, caz in care nu am ce completa
    cmp ebx, 0
    je complete_down_right

    ;; scad 8 pentru a merge o linie in jos si 1 pentru a merge o coloana la
    ;; stanga
    inc byte [ecx - 9]

complete_down_right:
    ;; verific daca sunt pe ultima coloana, deja am verificat pentru stanga jos
    ;; daca sunt pe prima linie
    cmp ebx, 7
    je complete_up_left

    ;; scad 8 pentru a merge o linie in jos si adaug 1 pentru a merge o coloana
    ;; la dreapta
    inc byte [ecx - 7]


complete_up_left:
    ;; verific daca sunt pe ultima linie, caz in care nu am ce completa
    cmp eax, 7
    je end

    ;; verific daca sunt pe prima coloana, caz in care nu am ce completa
    cmp ebx, 0
    je complete_up_right

    ;; adaug 8 pentru a merge o linie in sus si scad 1 pentru a merge o coloana
    ;; la stanga
    inc byte [ecx + 7]

complete_up_right:
    ;; verific daca sunt pe ultima coloana, am verificat daca sunt pe ultima
    ;; linie la stanga sus
    cmp ebx, 7
    je end

    ;; adaug 8 pentru a merge o linie in sus si 1 pentru a merge o coloana la
    ;; dreapta
    inc byte [ecx + 9]

end:
    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY