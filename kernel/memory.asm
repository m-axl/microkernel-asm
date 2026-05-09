; ============================================================================
; Minimal page-frame allocator state.
; ============================================================================

init_memory:
    mov word [free_mem], MEMORY_BASE
    ret

alloc_page:
    mov ax, [free_mem]
    add word [free_mem], PAGE_SIZE
    cmp word [free_mem], MEMORY_LIMIT
    jbe .done
    xor ax, ax
.done:
    ret

free_mem dw 0
