extern array_idx_1      ;; int array_idx_1

section .text
    global inorder_parc

;   struct node {
;       int value;
;       struct node *left;
;       struct node *right;
;   } __attribute__((packed));

;;  inorder_parc(struct node *node, int *array);
;       functia va parcurge in inordine arborele binar de cautare, salvand
;       valorile nodurilor in vectorul array.
;    @params:
;        node  -> nodul actual din arborele de cautare;
;        array -> adresa vectorului unde se vor salva valorile din noduri;

; ATENTIE: vectorul array este INDEXAT DE LA 0!
;          Cititi SI fisierul README.md din cadrul directorului pentru exemple,
;          explicatii mai detaliate!
; HINT: folositi variabila importata array_idx_1 pentru a retine pozitia
;       urmatorului element ce va fi salvat in vectorul array.
;       Este garantat ca aceasta variabila va fi setata pe 0 la fiecare
;       test.

inorder_parc:
    enter 0, 0
    pusha

    mov eax, [ebp + 8]
    mov ecx, [ebp + 12]
    xor edx, edx
    
go_left:
    mov ebx, [eax + 4]
    cmp ebx, 0
    je print

    pusha

    push ecx
    push ebx
    call inorder_parc
    pop ebx
    pop ecx

    popa

print:
    mov edi, [eax]
    mov dx, word [array_idx_1]
    mov [ecx + edx * 4], edi
    inc word [array_idx_1]

go_right:
    mov ebx, [eax + 8]
    cmp ebx, 0
    je end

    pusha

    push ecx
    push ebx
    call inorder_parc
    pop ebx
    pop ecx

    popa

end:
    popa
    leave
    ret
