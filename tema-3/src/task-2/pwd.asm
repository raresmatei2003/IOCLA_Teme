section .data
	back db "..", 0
	curr db ".", 0
	slash db "/", 0
	cuv dw 0 ;; numarul de cuvinte din path
	; declare global vars here

section .text
	global pwd
	extern strcmp
	extern strcat

;;	void pwd(char **directories, int n, char *output)
;	Adauga in parametrul output path-ul rezultat din
;	parcurgerea celor n foldere din directories
pwd:
	enter 0, 0
	pusha

	;; resetez numarul de cuvinte din path-ul calculat anterior
	mov word [cuv], 0

	mov eax, [ebp + 8] ;; directories
	mov edi, [ebp + 12] ;; n
	mov ecx, [ebp + 16] ;; output

	;; folosesc ebx pentru a parcurge vectorul de cuvinte
	xor ebx, ebx

traverse_words:
	mov edx, [eax + ebx * 4]

	;; compara cuvantul cu ".."
verify_if_back:
	pusha

	push edx
	push back
	call strcmp
	pop edx
	pop edx

	cmp eax, 0
	popa
	je is_back

is_not_back:
	jmp verify_if_curr

	;; executa instructiunea "cd .."
is_back:
	;; daca nu am cuvinte in path atunci instructiunea "cd .." nu face nimic
	cmp word [cuv], 0
	je next_word

	;; daca am cuvinte in path atunci il scot pe ultimul (ii elimin indicele
	;; din stiva)
	dec word [cuv]
	pop edx
	jmp next_word

	;; compara cuvantul cu "."
verify_if_curr:
	pusha

	push edx
	push curr
	call strcmp
	pop edx
	pop edx

	;; daca e "." atunci nu il punem pe stiva
	cmp eax, 0
	popa
	je next_word

	;; pun indicele cuvantului pe stiva
	inc word [cuv]
	push ebx

next_word:
	inc ebx
	cmp ebx, edi
	jl traverse_words

	;; retin in ebx indicele primului cuvant din path (primul introdus pe
	;; stiva)
	mov ebx, [cuv]
	dec ebx

	;; parcurge stiva
print_path:
	;; extrag indicele din stiva
	mov edx, [esp + ebx * 4]

	pusha

	;; extrag cuvantul de pe pozitia retinuta in edx
	mov ebx, [eax + edx * 4]

	;; pun "\" in path
	push slash
	push ecx
	call strcat
	pop ecx
	pop edx

	;; pun cuvantul in path
	push ebx
	push ecx
	call strcat
	pop ecx
	pop edx


	popa

	dec ebx
	cmp ebx, 0
	jge print_path

	;; pun ultimul "\" in path
	push slash
	push ecx
	call strcat
	pop ecx
	pop edx


	;; scot indicii cuvintelor de pe stiva
	xor ebx, ebx
pop_poz:
	pop edx
	inc ebx
	cmp ebx, [cuv]
	jl pop_poz

end:

	popa
	leave
	ret