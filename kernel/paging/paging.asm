; ============================================================================
; Paging Module - runtime PML4 metadata and simple physical page allocator
; ============================================================================

[bits 64]

PAGE_ALLOC_BASE equ 0x200000
PAGE_ALLOC_END  equ 0x10000000

paging_next_free dq PAGE_ALLOC_BASE
paging_allocated dq 0

paging_init:
    mov qword [paging_next_free], PAGE_ALLOC_BASE
    mov qword [paging_allocated], 0
    ret

page_alloc:
    mov rax, [paging_next_free]
    cmp rax, PAGE_ALLOC_END
    jae .fail
    add qword [paging_next_free], PAGE_SIZE
    inc qword [paging_allocated]
    ret
.fail:
    xor rax, rax
    ret

page_free:
    ; M2 uses a bump allocator only. Real free-list/bitmap belongs in M3+.
    ret

paging_stats:
    mov rax, [paging_allocated]
    mov rdx, PAGE_ALLOC_END - PAGE_ALLOC_BASE
    shr rdx, 12
    sub rdx, rax
    ret
