%include "../include/io.mac"

;; defining constants, you can use these as immediate values in your code
LETTERS_COUNT EQU 26

section .data
    extern len_plain

section .text
    global rotate_x_positions
    global enigma

rotate_x_positions:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; x
    mov ebx, [ebp + 12] ; rotor
    mov ecx, [ebp + 16] ; config (address of first element in matrix)
    mov edx, [ebp + 20] ; forward
    ;; DO NOT MODIFY
    ;; TODO: Implement rotate_x_positions
    ;; FREESTYLE STARTS HERE

    ;; daca x e 0 inseamna ca nu se fac modificari
    cmp eax, 0
    je end_rotations


    push eax
    push edx
    ;; inmultesc ebx cu 52 pentru a afla cati octeti sunt de la inceputul
    ;; matricei pana la inceputul rotorului cu indicele dat
    mov eax, ebx
    mov edx, LETTERS_COUNT * 2
    mul edx
    ;; adaug la ecx valoarea obtinuta, ecx aratand acum catre rotorul cu
    ;; indicele dat
    add ecx, eax
    pop edx
    pop eax

    xor ebx, ebx

    cmp edx, 0
    jg rotate_right

rotate_left:
    mov ebx, eax

push_first_x_elem:
    dec ebx
    mov dl, [ecx + ebx]
    push edx
    mov dl, [ecx + ebx + LETTERS_COUNT]
    push edx
    cmp ebx, 0
    jg push_first_x_elem

    xor ebx, ebx

move_to_left:
    xor edx, edx

    ;; iau literele ce se afla cu offset pozitii la stanga si le mut
    ;; pe pozitia actuala
    add ebx, eax
    mov dl, byte [ecx + ebx]
    sub ebx, eax
    mov [ecx + ebx], dl

    add ebx, eax
    mov dl, byte [ecx + ebx + LETTERS_COUNT]
    sub ebx, eax
    mov [ecx + ebx + LETTERS_COUNT], dl

    ;; verific daca am parcurs toate literele ce trebuie mutate (nr total
    ;; de litere din alfabet - offset)
    inc ebx
    mov edx, LETTERS_COUNT - 1
    sub edx, eax
    cmp ebx, edx
    jle move_to_left

pop_into_last_x_elem:
    ;; incepand de la pozitia obtinuta la mutarea la stanga scot de pe stiva
    ;; literele
    pop edx
    mov [ecx + ebx + LETTERS_COUNT], dl
    pop edx
    mov [ecx + ebx], dl

    inc ebx
    cmp ebx, LETTERS_COUNT
    jl pop_into_last_x_elem

    jmp end_rotations

rotate_right:
    ;; permutarea la dreapta cu offset pozitii este echivalenta cu permutarea
    ;; la stanga cu LETTERS_COUNT - offset pozitii
    mov edx, LETTERS_COUNT
    sub edx, eax
    mov eax, edx
    xor edx, edx
    jmp rotate_left


end_rotations:

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY

enigma:
    ;; DO NOT MODIFY
    push ebp
    mov ebp, esp
    pusha

    mov eax, [ebp + 8]  ; plain (address of first element in string)
    mov ebx, [ebp + 12] ; key
    mov ecx, [ebp + 16] ; notches
    mov edx, [ebp + 20] ; config (address of first element in matrix)
    mov edi, [ebp + 24] ; enc
    ;; DO NOT MODIFY
    ;; TODO: Implement enigma
    ;; FREESTYLE STARTS HERE
    
    ;; contor pentru parcurgere plain
    xor esi, esi

codificare:
    push esi

    push eax
    mov esi, 0

verify_notches:
    ;; daca key-ul pentru rotorul esi + 1 este egal cu notch-ul pentru
    ;; acelasi rotor, atunci tori rotorii incepand de la indicele esi trebuie
    ;; rotiti
    ;; key[1] == notch[1] => pozitia de inceput a rotorului 2 este noth-ul
    ;; deci rotorii 1 si 2 se rotesc, iar rotorul 3 este rotit mereu
    ;; key[2] == notch[2] => pozitia de inceput a rotorului 1 este noth-ul
    ;; deci rotorii 2 si 3 se rotesc
    ;; daca niciun rotor nu e pe notch atunci se roteste doar rotorul 3
    xor eax, eax
    mov al, [ebx + esi +1]
    cmp al, [ecx + esi + 1]
    je rotate_rotor

    inc esi
    cmp esi, 2
    je rotate_rotor

    jmp verify_notches

rotate_rotor:
    ;; ROTIRE CU O POZITIE LA STANGA A ROTORULUI CU INDICELE ESI

    push byte 0
    push edx
    push esi
    push byte 1

    call rotate_x_positions

    pop eax
    pop eax
    pop eax
    pop eax

    ;; SFARSIT APEL FUNCTIE

    cmp byte [ebx + esi], 'Z'
    je is_Z
    ;; daca nu e 'Z' atunci doar adaugam 1
    inc byte [ebx + esi]
    jmp next_rotation

is_Z:
    ;; prin rotirea literei 'Z' obtinem 'A'
    mov byte [ebx + esi], 'A'
    
next_rotation:
    inc esi
    cmp esi, 3
    jl rotate_rotor

    pop eax

    pop esi

    ;; pun in stiva notch-urile
    push ecx
    ;; retin in ecx caracterul de pe pozitia esi din plain
    xor ecx, ecx
    mov cl, [eax + esi]
    sub cl, 'A'

    ;; plugboard
    mov cl, [edx + LETTERS_COUNT * 9 + ecx]
    sub cl, 'A'

    ;; pun in stiva indicele literei din plain la care am ajuns
    push esi

    mov esi, 3
    add edx, LETTERS_COUNT * 7

rotors:
    dec esi
    sub edx, 2 * LETTERS_COUNT

    mov cl, [edx + ecx]
    cmp cl, [edx - LETTERS_COUNT]
    jge bigger_than_key
    add cl, LETTERS_COUNT

bigger_than_key:
    sub cl, [edx - LETTERS_COUNT]

    cmp esi, 0
    jg rotors
    
    ;; reflector
    add edx, 6 * LETTERS_COUNT
    mov cl, byte [edx + ecx]
    sub cl, 'A'

    xor esi, esi
    sub edx, 7 * LETTERS_COUNT

backwards_rotors:
    mov cl, [edx + ecx]

    push esi
    xor esi, esi
    dec esi

find_char:
    inc esi
    cmp cl, byte [edx + LETTERS_COUNT + esi]
    jne find_char

    mov ecx, esi
    pop esi

    inc esi
    add edx, 2 * LETTERS_COUNT
    cmp esi, 3
    jl backwards_rotors

    ;; backwards plugboard
    add edx, 3 * LETTERS_COUNT
    mov cl, [edx + ecx]
    pop esi
    mov byte [edi + esi], cl
    pop ecx
    sub edx, 9 * LETTERS_COUNT
    inc esi
    cmp esi, [len_plain]
    jl codificare

    ;; FREESTYLE ENDS HERE
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY