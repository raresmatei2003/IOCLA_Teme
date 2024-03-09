extern array_idx_2      ;; int array_idx_2

section .text
    global inorder_intruders

;   struct node {
;       int value;
;       struct node *left;
;       struct node *right;
;   } __attribute__((packed));

;;  inorder_intruders(struct node *node, struct node *parent, int *array)
;       functia va parcurge in inordine arborele binar de cautare, salvand
;       valorile nodurilor care nu respecta proprietatea de arbore binar
;       de cautare: |node->value > node->left->value, daca node->left exista
;                   |node->value < node->right->value, daca node->right exista
;
;    @params:
;        node   -> nodul actual din arborele de cautare;
;        parent -> tatal/parintele nodului actual din arborele de cautare;
;        array  -> adresa vectorului unde se vor salva valorile din noduri;

; ATENTIE: DOAR in frunze pot aparea valori gresite!
;          vectorul array este INDEXAT DE LA 0!
;          Cititi SI fisierul README.md din cadrul directorului pentru exemple,
;          explicatii mai detaliate!

; HINT: folositi variabila importata array_idx_2 pentru a retine pozitia
;       urmatorului element ce va fi salvat in vectorul array.
;       Este garantat ca aceasta variabila va fi setata pe 0 la fiecare
;       test al functiei inorder_intruders.      

inorder_intruders:
    enter 0, 0

    pusha

    mov eax, [ebp + 8] ;; nodul curent
    mov ebx, [ebp + 12] ;; nodul tata
    mov ecx, [ebp + 16] ;; array
    xor edx, edx
    
verify_leaf:
    ;; verific daca nodul curent are fiu in stanga
    cmp dword [eax + 4], 0
    jg go_left

    ;; verific daca nodul curent are fiu in dreapta
    cmp dword [eax + 8], 0
    jg go_right

    ;; verific daca nodul curent este radacina (nu are tata)
    cmp ebx, 0
    je end

    ;; verific daca nodul curent e fiul din stanga a tatalui
    mov edx, [ebx + 4]
    cmp edx, eax
    je verify_left

    ;; verific daca nodul curent este mai mare decat tatal
verify_right:
    mov eax, [eax]
    mov ebx, [ebx]
    cmp eax, ebx
    jg end

    ;; nodul curent este mai mic si il introduc in array
    xor edx, edx
    mov edx, dword [array_idx_2]
    mov [ecx + 4 * edx], eax
    inc dword [array_idx_2]
    jmp end

    ;; verific daca nodul curent este mai mic decat tatal
verify_left:
    mov eax, [eax]
    mov ebx, [ebx]
    cmp eax, ebx
    jl end

    ;; nodul curent este mai mare si il introduc in array
    xor edx, edx
    mov edx, dword [array_idx_2]
    mov [ecx + 4 * edx], eax
    inc dword [array_idx_2]
    jmp end

go_left:
    mov edx, [eax + 4]
    
    pusha

    push ecx
    push eax
    push edx
    call inorder_intruders
    pop edx
    pop eax
    pop ecx

    popa

go_right:
    mov edx, [eax + 8]
    cmp edx, 0
    je end

    pusha

    push ecx
    push eax
    push edx
    call inorder_intruders
    pop edx
    pop eax
    pop ecx

    popa

end:
    popa

    leave
    ret
