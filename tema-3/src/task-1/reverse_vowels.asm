section .data
	vowels db "aeiou", 0
	; declare global vars here

section .text
	global reverse_vowels
	extern strchr

;;	void reverse_vowels(char *string)
;	Cauta toate vocalele din string-ul `string` si afiseaza-le
;	in ordine inversa. Consoanele raman nemodificate.
;	Modificare se va face in-place
reverse_vowels:
	;; extrag in eax string-ul
	push ebp
	push esp
	pop ebp
	
	push dword [ebp + 8]
	pop ecx

	pusha

	;; voi retine in edx lungimea string-ului
	xor edx, edx

	;; eax va fi folosit pentru a retine output-ul functiei strchr

	;; pune pe stiva vocalele in ordinea in care le gaseste
find_vowels:
	;; extragere litera
	xor ebx, ebx
	add bl, byte [ecx]
	
	pusha

	push ebx
	push vowels
	call strchr
	pop ecx
	pop ecx

	cmp eax, 0
	popa
	jg is_vowel

is_not_vowel:
	jmp next_char

is_vowel:
	push ebx
	jmp next_char


next_char:
	inc ecx
	inc edx
	cmp byte [ecx] , 0
	jg find_vowels

	;; ma intorc la inceputul string-ului
	sub ecx, edx


find_vowels_again:
	;; extragere litera
	xor ebx, ebx
	add bl, [ecx]
	
	pusha

	push ebx
	push vowels
	call strchr
	pop ecx
	pop ecx

	cmp eax, 0
	popa
	jg replace_vowel

do__not_replace_vowel:
	jmp next_char_again

replace_vowel:
	pop eax
	sub byte [ecx], bl
	add byte [ecx], al
	jmp next_char_again


next_char_again:
	inc ecx
	cmp byte [ecx] , 0
	jg find_vowels_again

	popa

	pop ebp
	ret