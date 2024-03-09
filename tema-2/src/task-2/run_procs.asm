%include "../include/io.mac"

    ;;
    ;;   TODO: Declare 'avg' struct to match its C counterpart
    ;;

struc avg
    .quo: resw 1
    .remain: resw 1
endstruc

struc proc
    .pid: resw 1
    .prio: resb 1
    .time: resw 1
endstruc

    ;; Hint: you can use these global arrays
section .data
    prio_result dd 0, 0, 0, 0, 0
    time_result dd 0, 0, 0, 0, 0

section .text
    global run_procs

run_procs:
    ;; DO NOT MODIFY

    push ebp
    mov ebp, esp
    pusha

    xor ecx, ecx

clean_results:
    mov dword [time_result + 4 * ecx], dword 0
    mov dword [prio_result + 4 * ecx],  0

    inc ecx
    cmp ecx, 5
    jne clean_results

    mov ecx, [ebp + 8]      ; processes
    mov ebx, [ebp + 12]     ; length
    mov eax, [ebp + 16]     ; proc_avg
    ;; DO NOT MODIFY
   
    ;; Your code starts here

    xor edx, edx

    ;; inmultesc ebx cu dimensiunea structurii proc
    push eax
    mov eax, ebx
    mov ebx, proc_size
    mul ebx
    mov ebx, eax
    pop eax
    xor edx, edx

traverse_vector:
    push ebx
    ;; retin timpul de la elemntul actual
    mov bx, [ecx + edx + proc.time]

    ;; retin prioritatea elementului de pe pozitia edx din vector
    push edx
    push eax
    mov eax, edx
    xor edx, edx
    mov dl, [ecx + eax + proc.prio]
    pop eax
    ;; scad 1 deoarece indexarea in vectori incepe de la 0
    dec dl
    
    ;; adaug timpul la suma prioritatii gasite
    add ebx, [time_result + 4 * edx]
    mov [time_result + 4 * edx], ebx

    ;; cresc frecventa prioritatii gasite in vector
    xor ebx, ebx
    mov ebx, [prio_result + 4 * edx]
    inc ebx
    mov [prio_result + 4 * edx], ebx

    pop edx
    pop ebx

    ;; trec la urmatorul element din vectorul de procese
    add edx, proc_size
    cmp edx, ebx
    jl traverse_vector

    ;; am terminat de completat vectorii time_result si prio_result

    ;; retin in ecx adresa vectorului proc_avg
    mov ecx, eax

    xor eax, eax
    xor ebx, ebx
    xor edx, edx

result_traverse:
    xor eax, eax
    xor edx, edx
    mov eax, [time_result + 4 * ebx]
    mov edx, [prio_result + 4 * ebx]

    push ebx
    mov ebx, edx
    xor edx, edx

    ;; verific daca trebuie sa impart la 0
    cmp ebx, 0
    je put_in_out

    div ebx

put_in_out:
    pop ebx
    mov [ecx + ebx * 4 + avg.quo], ax
    mov [ecx + ebx * 4 + avg.remain], dx

    inc ebx
    cmp ebx, 5
    jl result_traverse
    
    mov eax, ecx

    ;; Your code ends here
    
    ;; DO NOT MODIFY
    popa
    leave
    ret
    ;; DO NOT MODIFY