.global cspush
.global cspop
.global cstop
.data
    cstop: .quad 0
.text
cspush:
    mov $16, %rdi
    call malloc@PLT
    push %rax
    mov cstop(%rip), %rax
    mov (%rax),%rdi
    call copymatrix
    mov %rax, %rdx
    pop %rax
    mov %rdx, (%rax)
    mov cstop(%rip), %rsi
    mov %rsi, 8(%rax)
    mov %rax, cstop(%rip)
    ret
cspop:
    mov cstop(%rip), %rdi
    mov (%rdi), %rdi
    call freematrix
    //do some stuff first?
    mov cstop(%rip), %rdi
    mov 8(%rdi), %rsi
    mov %rsi, cstop(%rip)
    call free@PLT
    ret
