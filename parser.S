.macro cspeek
    mov cstop(%rip), %rdi
    mov (%rdi), %rdi
.endm
.macro args4
    call inpstream
    lea buf(%rip), %rdi
    mov $4, %rsi
    call getargs
    mov $4, %rdi
    call convertargs
    lea args(%rip), %r8
    movsd 0(%r8), %xmm3
    movsd 8(%r8), %xmm2
    movsd 16(%r8), %xmm1
    movsd 24(%r8), %xmm0
    mov edgem(%rip), %rdi
.endm
.macro args6
    call inpstream
    lea buf(%rip), %rdi
    mov $6, %rsi
    call getargs
    mov $6, %rdi
    call convertargs
    lea args(%rip), %r8
    movsd 0(%r8), %xmm5
    movsd 8(%r8), %xmm4
    movsd 16(%r8), %xmm3
    movsd 24(%r8), %xmm2
    movsd 32(%r8), %xmm1
    movsd 40(%r8), %xmm0
    mov edgem(%rip), %rdi
.endm
.macro args3
    call inpstream
    lea buf(%rip),%rdi
    mov $3, %rsi
    call getargs
    mov $3, %rdi
    call convertargs
    lea args(%rip), %r8
    movsd 0(%r8), %xmm2
    movsd 8(%r8), %xmm1
    movsd 16(%r8), %xmm0
    cspeek
.endm
.macro args5
    call inpstream
    lea buf(%rip), %rdi
    mov $5, %rsi
    call getargs
    mov $5, %rdi
    call convertargs
    lea args(%rip), %r8
    movsd 0(%r8), %xmm4
    movsd 8(%r8), %xmm3
    movsd 16(%r8), %xmm2
    movsd 24(%r8), %xmm1
    movsd 32(%r8), %xmm0
    mov edgem(%rip), %rdi
.endm
.macro args8
    call inpstream
    lea buf(%rip), %rdi
    mov $8, %rsi
    call getargs
    mov $8, %rdi
    call convertargs
    lea args(%rip), %r8
    movsd 0(%r8), %xmm7
    movsd 8(%r8), %xmm6
    movsd 16(%r8), %xmm5
    movsd 24(%r8), %xmm4
    movsd 32(%r8), %xmm3
    movsd 40(%r8), %xmm2
    movsd 48(%r8), %xmm1
    movsd 56(%r8), %xmm0
    mov edgem(%rip), %rdi
.endm
.macro applytris
    cspeek
    mov trim(%rip), %rsi
    call multiplymatrix
    call drawtris
    mov trim(%rip), %rdi
    call clearedges
.endm
.macro applyedges
    cspeek
    mov edgem(%rip), %rsi
    call multiplymatrix
    mov edgem(%rip), %rdi
    mov $0xffffff, %rsi
    call drawedges
    mov edgem(%rip), %rdi
    call clearedges
.endm
.global parse
.data
    line: .asciz "line"
    scale: .asciz "scale"
    move: .asciz "move"
    rotate: .asciz "rotate"
    display: .asciz "display"
    save: .asciz "save"
    convert: .asciz "convert"
    circle: .asciz "circle"
    hermite: .asciz "hermite"
    bezier: .asciz "bezier"
    box: .asciz "box"
    sphere: .asciz "sphere"
    torus: .asciz "torus"
    cspushm: .asciz "push"
    cspopm: .asciz "pop"
.bss
    buf: .zero 1024
    curchar: .byte 0
    args: .zero 64
    lens: .zero 64
    streamdone: .byte 0
.text
//make a helper function to gather args
linel:
    call inpstream
    lea buf(%rip),%rdi
    mov $6, %rsi
    call getargs
    mov $6, %rdi
    call convertargs
    lea args(%rip), %r8
    movsd 0(%r8), %xmm5
    movsd 8(%r8), %xmm4
    movsd 16(%r8), %xmm3
    movsd 24(%r8), %xmm2
    movsd 32(%r8), %xmm1
    movsd 40(%r8), %xmm0
    mov edgem(%rip), %rdi
    call addedge
    applyedges
    jmp afterl
scalel:
    args3
    lea dilate(%rip), %rax
    call genmanipulate
    jmp afterl
movel:
    args3
    lea transform(%rip), %rax
    call genmanipulate
    jmp afterl
rotatel:
    call inpstream
    lea buf(%rip),%rdi
    mov $2, %rsi
    call getargs
    lea args(%rip), %r8
    mov 8(%r8), %rax
    push %rax
    mov $2, %rdi
    call convertargs
    lea args(%rip), %r8
    movsd (%r8), %xmm0
    call deg2rad
    pop %rax
    cmpb $0x79,(%rax)
    je doyro
    jg dozro
    lea rotatex(%rip), %rax
    jmp endro
    doyro:
    lea rotatey(%rip), %rax
    jmp endro
    dozro:
    lea rotatez(%rip), %rax
    endro:
    cspeek
    call genrotate
    jmp afterl
displayl:
    lea name(%rip), %rdi
    call pr
    vmovups name(%rip), %ymm1
    movsd display(%rip),%xmm0
    lea buf(%rip), %rdi
    movsd %xmm0, (%rdi)
    movb $0x20, 7(%rdi)
    //filename is limited to 31 characters
    vmovups %ymm1, 8(%rdi)
    call system@plt

    mov $87, %rax
    lea name(%rip), %rdi
    syscall//remove temporary file
    jmp afterl
savel:
    lea name(%rip), %rdi
    call pr
    call inpstream
    vmovups buf(%rip), %ymm1

    movsd convert(%rip),%xmm0
    movsd %xmm0, buf(%rip)
    lea buf(%rip), %rdi
    movb $0x20, 7(%rdi)
    //filename is limited to 31 characters
    movups name(%rip), %xmm0
    movups %xmm0, 8(%rdi)
    movb $0x20, 19(%rdi)
    vmovups %ymm1, 20(%rdi)
    call system@plt

    mov $87, %rax
    lea name(%rip), %rdi
    syscall//remove temporary file
    jmp afterl
circlel://Draw a circle
    args4
    call makecircle
    applyedges
    jmp afterl
spherel:
    args4
    call makesphere
    applytris
    jmp afterl
boxl:
    args6
    call makebox
    applytris
    jmp afterl
torusl:
    args5
    call maketorus
    applytris
    jmp afterl
hermitel://Draw a hermite curve
    args8
    lea hermitematrix(%rip), %rsi
    call makespline
    applyedges
    jmp afterl
bezierl://Draw a bezier curve
    args8
    lea beziermatrix(%rip), %rsi
    call makespline
    applyedges
    jmp afterl
cspushl://Draw a bezier curve
    call cspush
    jmp afterl
cspopl://Draw a bezier curve
    call cspop
    jmp afterl
inpstream://file descriptor in parsefd(%rip), returns a string in %rax, or 0 if an EOF is encountered
    mov parsefd(%rip), %rdi
    xor %rcx, %rcx
    lea curchar(%rip), %rsi
    mov $1, %rdx
    nchar:
    xor %rax, %rax
    push %rcx
    syscall
    pop %rcx
    mov curchar(%rip), %r8b
    lea buf(%rip), %r9
    movb %r8b, (%r9,%rcx)
    inc %rcx
    cmp $0, %rax
    jne noteof
    movb $0, (%r9,%rcx)
    movb $1, streamdone(%rip)
    ret
    noteof:
    cmp $'\n',curchar(%rip)
    jne nchar
    dec %rcx
    movb $0, (%r9,%rcx)
    lea buf(%rip), %rax
    ret
parse:
    parseloop:
    call inpstream
    mov %rax, %rdi
    movb streamdone(%rip), %al
    cmpb $1, %al
    je end

    lea line(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne linel

    lea scale(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne scalel

    lea move(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne movel

    lea rotate(%rip), %rsi
    call mstrcmp
    test %rax, %rax
    jne rotatel
    
    lea display(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne displayl
    
    lea save(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne savel

    lea circle(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne circlel

    lea hermite(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne hermitel

    lea bezier(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne bezierl

    lea box(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne boxl

    lea sphere(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne spherel

    lea torus(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne torusl

    lea cspushm(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne cspushl

    lea cspopm(%rip), %rsi
    call mstrcmp
    cmp $0, %rax
    jne cspopl

    afterl:
    movb streamdone(%rip), %al
    cmpb $1, %al
    je end
    //rax is the string
    jmp parseloop
    end:
    ret
strlen://rdi is the string
    xor %rax, %rax
    lstart:
    movb (%rdi, %rax), %cl
    testb %cl,%cl 
    je lenend
    inc %rax
    jmp lstart
    lenend:
    ret
mstrcmp://rdi is string 1, rsi is string 2
    xor %rax, %rax
    cmpstart:
    movb (%rdi, %rax), %cl
    test %cl, %cl
    je nend
    movb (%rsi, %rax), %dl
    cmpb %cl,%dl 
    jne nend
    inc %rax
    jmp cmpstart
    nend:
    movb (%rsi, %rax), %dl
    test %dl, %dl
    je yend
    mov $0, %rax
    ret
    yend:
    mov $1, %rax
    ret
convert2: //string in rdi, length in rsi
    xor %rdx, %rdx
    xor %rcx, %rcx
    xor %rax, %rax
    cmpb $0x2d,(%rdi)
    jne cvt2i
    inc %rdx
    cvt2i:
    imul $10, %rax
    movb (%rdi,%rdx), %cl
    subb $0x30, %cl
    add %rcx, %rax
    inc %rdx
    cmp %rdx, %rsi
    jne cvt2i
    cmpb $0x2d, (%rdi)
    jne afterneg
    neg %rax
    afterneg:
    ret
convertargs://number of args is in %rdi, converts all the args to ints, rather than pointers
    dec %rdi
    cmp $0, %rdi
    jl convertaend
    lea args(%rip), %r8
    lea lens(%rip), %r9
    push %rdi
    mov (%r9,%rdi,8),%rsi
    shl $3, %rdi
    add %r8, %rdi
    mov (%rdi), %rdi
    call convert2
    pop %rdi
    cvtsi2sd %rax, %xmm0
    movsd %xmm0, (%r8,%rdi,8)
    jmp convertargs
    convertaend:
    ret
    
getargs: //input in %rdi, count in %rsi, output is in args
    xor %rax, %rax
    dec %rsi
    cmp $0, %rsi
    jl getend
    argstart:
    movb (%rdi, %rax), %cl
    or $0x20, %cl
    cmpb $0x20,%cl 
    je argend
    inc %rax
    jmp argstart
    argend:
    lea args(%rip),%r8
    mov %rdi, (%r8,%rsi,8)
    lea lens(%rip),%r8
    mov %rax, (%r8,%rsi,8)
    inc %rax
    add %rax, %rdi
    jmp getargs
    getend:
    ret
