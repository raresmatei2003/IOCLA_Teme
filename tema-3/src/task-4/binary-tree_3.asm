section .text
    global inorder_fixing

;   struct node {
;       int value;
;       struct node *left;
;       struct node *right;
;   } __attribute__((packed));

;;  inorder_fixing(struct node *node, struct node *parent)
;       functia va parcurge in inordine arborele binar de cautare, modificand
;       valorile nodurilor care nu respecta proprietatea de arbore binar
;       de cautare: |node->value > node->left->value, daca node->left exista
;                   |node->value < node->right->value, daca node->right exista.
;
;       Unde este nevoie de modificari se va aplica algoritmul:
;           - daca nodul actual este fiul stang, va primi valoare tatalui - 1,
;                altfel spus: node->value = parent->value - 1;
;           - daca nodul actual este fiul drept, va primi valoare tatalui + 1,
;                altfel spus: node->value = parent->value + 1;

;    @params:
;        node   -> nodul actual din arborele de cautare;
;        parent -> tatal/parintele nodului actual din arborele de cautare;

; ATENTIE: DOAR in frunze pot aparea valori gresite! 
;          Cititi SI fisierul README.md din cadrul directorului pentru exemple,
;          explicatii mai detaliate!

inorder_fixing:
    enter 0, 0

    pusha

    mov eax, [ebp + 8] ;; nodul curent
    mov ebx, [ebp + 12] ;; nodul tata
    xor ecx, ecx
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
    mov ecx, [eax]
    mov edx, [ebx]
    cmp ecx, edx
    jg end

    ;; nodul curent este mai mic si il introduc in array
    inc edx
    mov dword [eax], edx
    jmp end

    ;; verific daca nodul curent este mai mic decat tatal
verify_left:
    mov ecx, [eax]
    mov edx, [ebx]
    cmp ecx, edx
    jl end

    ;; nodul curent este mai mare si il introduc in array
    dec edx
    mov dword [eax], edx
    jmp end

    
go_left:
    mov edx, [eax + 4]
    
    pusha

    push eax
    push edx
    call inorder_fixing
    pop edx
    pop eax

    popa

go_right:
    mov edx, [eax + 8]
    cmp edx, 0
    je end

    pusha

    push eax
    push edx
    call inorder_fixing
    pop edx
    pop eax

    popa

end:
    popa

    leave
    ret
