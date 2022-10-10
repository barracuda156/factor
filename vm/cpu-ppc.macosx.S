    .file "cpu-ppc.macosx.S"
    .text
    .align 2
    .globl flush_icache
_flush_icache:
    add r4,r4,r3    ; end += ptr
#ifdef __ppc64__
    clrrdi r3,r3,5  ; ptr &= ~0x1f
#else
    clrrwi r3,r3,5  ; ptr &= ~0x1f
#endif
    sub r4,r4,r3    ; end -= aligned_ptr
    addi r4,r4,0x1f ; end += 0x1f
#ifdef __ppc64__
    srdi. r4,r4,5   ; end >>= 5, set cr
#else
    srwi. r4,r4,5   ; end >>= 5, set cr
#endif
    beqlr

    ; Loop over the buffer by cache line and flush the data cache.
    mr r5,r3
    mtctr r4
loop1:
    dcbst 0,r5
    addi r5,r5,0x20
    bdnz loop1

    ; Synchronize to ensure the cache line flushes are complete.
    sync

    # Loop over the buffer by cache line and flush the instruction cache.
    mr r5,r3
    mtctr r4
loop2:
    icbi 0,r5
    addi r5,r5,0x20
    bdnz loop2

    ; Clear instruction pipeline to force reloading of instructions.
    isync
    blr
